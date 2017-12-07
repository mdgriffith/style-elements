"""
This script captures all the checks that should be performed before publishing a new version.


    1. All examples compile
    2. All examples are published in Ellies (the sequencing here might be a little weird)
    3. Spellcheck has been run in the docs. (notify if any typo is found, pause for it to be addressed)
    4. Examples in the documentation compile.
    5. Test suite
        - Layout tests via browser automation are generated
        - Benchmarks are run via browser automation.  Test cases are generated if new version has a speed regression.
        - Normal tests are added
        - All tests must pass

"""