# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin 'application', preload: true
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true
pin '@hotwired/stimulus', to: 'stimulus.min.js', preload: true
pin '@hotwired/stimulus-loading', to: 'stimulus-loading.js', preload: true
pin_all_from 'app/javascript/controllers', under: 'controllers'
# pin 'chartkick', to: 'https://ga.jspm.io/npm:chartkick@5.0.1/dist/chartkick.esm.js'
# pin 'chart.js', to: 'https://ga.jspm.io/npm:chart.js@4.5.1/dist/chart.js'
# pin '@kurkle/color', to: 'https://ga.jspm.io/npm:@kurkle/color@0.3.4/dist/color.esm.js'
pin 'chartkick', to: 'chartkick.js'
pin 'Chart.bundle', to: 'Chart.bundle.js'
