# This script reads an OBO file using the obo_parser and outputs a JSON file that is then used by the crystal scripts.
# The JSON file looks like this:
# {
#   "parents": {
#     "GO:122335": ["GO:4433", "GO:5432"],
#     "GO:122341": ["GO:1243", "GO:1532"],
#     ...
#   },
#   "main_id" : {"GO:1443":"GO:532", "GO:2533":"GO:5234"}
#   "obsolete": ["GO:1432", "GO:4322", ...]
# }

import obo_parser
import json

parents = {}
main_id = {}
obsolete = []
with open("go.obo") as obofile:
  parser = obo_parser.Parser(obofile)
  for stanza in parser:
    if not stanza.name == "Term":
      continue

    go_id = stanza.tags["id"][0]

    if 'is_a' in stanza.tags:
      parents[go_id] = stanza.tags['is_a']
    else:
      parents[go_id] = []

    if 'alt_id' in stanza.tags:
      for alt_id in stanza.tags['alt_id']:
        main_id[alt_id] = go_id

    if 'is_obsolete' in stanza.tags and stanza.tags['is_obsolete'][0] == "true":
      obsolete.append(go_id)

with open('slimGO.json', 'w') as f:
  f.write(json.dumps({"parents":parents,"main_id":main_id,"obsolete":obsolete},indent=2))

