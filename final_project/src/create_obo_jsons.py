# This script reads an OBO file using the obo_parser and outputs JSON files that are then used by the crystal scripts.
# The slimGO.JSON file looks like this:
# {
#   "parents": {
#     "GO:122335": ["GO:4433", "GO:5432"],
#     "GO:122341": ["GO:1243", "GO:1532"],
#     ...
#   },
#   "main_id" : {"GO:1443":"GO:532", "GO:2533":"GO:5234"}
#   "obsolete": ["GO:1432", "GO:4322", ...]
# }
#
# The go_names.json file looks like this:
# {
#   "GO:43334":"Photosynthesis",
#   "GO:93743":"Something else",
#   ...
# }

import obo_parser
import json

parents = {}
main_id = {}
obsolete = []
go_names = {}
with open("resources/go.obo") as obofile:
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
    else:
      go_names[go_id] = stanza.tags['name'][0]

with open('slimGO.json', 'w') as f:
  f.write(json.dumps({"parents":parents,"main_id":main_id,"obsolete":obsolete},indent=2))

with open('go_names.json', 'w') as f:
  f.write(json.dumps(go_names,indent=2))
