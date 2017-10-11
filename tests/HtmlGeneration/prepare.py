

"""
This will scan the viewSnippets.elm file and prepare the elm-static-html config to grab every view function.
"""

import re
import json

if __name__ == "__main__":

    snippetFile = 'HtmlGeneration/Snippets.elm'

    with open(snippetFile) as VIEW:
        views = VIEW.read()
        sections = views.split("{- views -}")
        # print(sections[1])
        found = re.findall(r"\n(\w+)\s=", sections[1])
        
        config = {
            "files": {
                snippetFile: [{"output": "HtmlGeneration/rendered/" + view + ".html" , "viewFunction": view } for view in found ]
            }
        }
        with open('elm-static-html.json', 'w') as CONFIG:
            CONFIG.write(json.dumps(config, indent=4))



