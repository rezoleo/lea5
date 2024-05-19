# Install in production

1. Install git, [rbenv build deps][rbenv-build-deps], PostgreSQL, `libpq-dev`, `postfix` (follow https://poly.rezoleo.fr/doku.php?id=private:services:mail)
2. Create `lea5` user
3. Create `/opt/lea5` and chown to `lea5`
4. `su - lea5`
5. Install rbenv and rbenv-build
6. `git clone https://github.com/rezoleo/lea5.git`
7. `rbenv install`, check with `ruby -v`
8. `gem install bundler`
9. `bundle config set --local deployment 'true'`
10. `bundle install`
11. `bundle binstubs puma`
12. `su - postgres -c 'createuser lea5 --createdb --pwprompt'`
13. `su - postgres -c 'createdb lea5_production --owner=lea5'`
14. `read -rs RAILS_MASTER_KEY`, enter the key from Vault (secret `lea5:production.key`)
15. `RAILS_ENV=production rails db:migrate`
16. `RAILS_ENV=production rails assets:precompile`
17. `RAILS_ENV=production bin/puma -b unix:///opt/lea5/puma-lea5.sock`
18. `RAILS_ENV=production bin/rails server --log-to-stdout --binding 127.0.0.1`
19. Configure nginx:
    ```nginx
    upstream lea5 {
      server unix:///opt/lea5/tmp/sockets/puma-lea5.sock;
    }

    server {
      listen 80;
      server_name _;

      root /opt/lea5/public;
      access_log /opt/lea5/log/nginx.access.log;
      error_log /opt/lea5/log/nginx.error.log info;

      try_files $uri/index.html $uri @proxy;
      error_page 500 502 503 504 /500.html;

      location @proxy {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header  X-Forwarded-Proto $scheme;
        proxy_set_header  X-Forwarded-Ssl on; # Optional
        proxy_set_header  X-Forwarded-Port $server_port;
        proxy_set_header  X-Forwarded-Host $host;
        proxy_pass http://lea5;
      }

      location /assets {
        gzip_static on;
        root /opt/lea5/public;
      }
    }
    ```
20. Configure systemd `/etc/systemd/system/lea5.service`
    ```systemd
    [Unit]
    Description=Lea5 - Main server
    Documentation=https://github.com/rezoleo/lea5
    After=network.target
    After=nginx.service
    Requires=nginx.service
    
    [Service]
    Type=simple
    User=lea5
    Group=lea5
    WorkingDirectory=/opt/lea5
    ExecStart=/opt/lea5/bin/rails server --log-to-stdout --binding 127.0.0.1
    Restart=on-failure
    Environment=PATH=/home/lea5/.rbenv/shims:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin
    Environment=RAILS_ENV=production
    Environment=RAILS_MASTER_KEY=<insert master key here>
    
    [Install]
    WantedBy=multi-user.target
    ```

**⚠️TODO:** Use master key file instead of env variable?

---
[rbenv-build-deps]: https://github.com/rbenv/ruby-build/wiki#suggested-build-environment
