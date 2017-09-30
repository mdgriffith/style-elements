# Testing Style Elements

There are quite a few different aspects to test with regards to style-elements, some of which require uncommon testing techniques (like rendering to a browser and querying for what the browser thinks the position is).


## Overview of Test Folders

- *Visual* This is a series of tests that are not technically `Test`s, but require visual inspection.  It would be lovely to make them programmatically testable.
  - *CssReset.elm* The CSS reset should make sure that html node does not imply styling except for very specific situations.
  - *Master.elm* includes as many layout situations as possible.

- *HtmlGeneration* This is an area to inspect what html is generated in various situations.  We also use Noah's html-test library to guarantee certain situations result in specific html being generated.

- *Layout* 
