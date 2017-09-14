

"""
This will scan the viewSnippets.elm file and prepare the elm-static-html config to grab every view function.
"""

import re
import json

if __name__ == "__main__":
    with open('ViewSnippets.elm') as VIEW:
        views = VIEW.read()
        sections = views.split("{- views -}")
        # print(sections[1])
        found = re.findall(r"\n(\w+)\s=", sections[1])
        

        # Doesnt actually work
        config = {
            "files": {
                "ViewSnippets.elm": [{"output": "rendered/" + view + ".html" , "viewFunction": view } for view in found ]
            }
        }
        with open('elm-static-html.json', 'w') as CONFIG:
            CONFIG.write(json.dumps(config, indent=4))



