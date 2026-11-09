"""Export re2o accounts that still have internet access, for lea5:import_re2o_snapshot.

Run on the re2o server, after sales are frozen:
    python3 manage.py shell < export_snapshot.py > re2o_snapshot.json
"""
import json
import re

from django.utils import timezone

from machines.models import Interface
from users.models import Adherent

now = timezone.now()
accounts = []

for user in Adherent.objects.filter(state=Adherent.STATE_ACTIVE):
    # Same rule as User.has_access: adhesion and connexion both valid, or whitelisted
    end_connexion = user.end_connexion()
    end_adhesion = user.end_adhesion()
    paid_end = min(end_connexion, end_adhesion) if end_connexion and end_adhesion else None
    end_at = max(filter(None, [paid_end, user.end_whitelist()]), default=None)
    if end_at is None or end_at <= now or user.is_ban():
        continue

    machines = [
        {"mac": str(interface.mac_address), "name": interface.machine.name or ""}
        for interface in Interface.objects.filter(machine__user=user, machine__active=True)
    ]
    # hashNT returned bytes, which Django may have stored as the string "b'ABCD...'"
    ntlm_hash = re.sub(r"^b'(.*)'$", r"\1", user.pwd_ntlm or "")

    accounts.append({
        "pseudo": user.pseudo,
        "email": user.email,
        "firstname": user.name,
        "lastname": user.surname,
        "room": user.room.name if user.room else None,
        "end_at": end_at.isoformat(),
        "ntlm_hash": ntlm_hash,
        "machines": machines,
    })

print(json.dumps(accounts, indent=2))
