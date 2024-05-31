# -*- coding: utf-8 -*-
"""
Reads the output of Dart Code Metrics (DCM) and creates a JSON file with the
cyclomatic complexity of each function in each file.

Created on 2024-05-29 at 15:12:19
@author: Joachim Favre
"""
import re
import json

INPUT_PATH = "scripts/cyclomatic_complexity/dcm_out.txt"
OUTPUT_PATH = "scripts/cyclomatic_complexity/cyclomatic_complexity.json"


def dcm_out_to_dict(content: str) -> dict:
    """
    Converts the output of Dart Code Metrics (DCM), [content], to a dictionary.
    DCM should be parametrised to make a warning for each function with a cyclomatic
    complexity greater than 0.
    """
    FILE_PATTERN = r"^.* #### (.*):$"
    FUNC_PATTERN = r"^.* ALARM   (.*)$"
    COMPLEX_PATTERN = r"^.* cyclomatic complexity: (\d+)$"

    file_name = None
    function_name = None
    result = {}

    for line in content.split('\n'):
        file_match = re.match(FILE_PATTERN, line)
        func_match = re.match(FUNC_PATTERN, line)
        complex_match = re.match(COMPLEX_PATTERN, line)
        if file_match:
            file_name = file_match.group(1)
            result[file_name] = {}
        elif func_match:
            if file_name is None:
                raise Exception("A function should be in a file.")
            function_name = func_match.group(1)
        elif complex_match:
            if function_name is None:
                raise Exception("A complexity should be relative to a single function.")
            complexity = int(complex_match.group(1))
            result[file_name][function_name] = complexity
            function_name = None
    
    return result


if __name__ == "__main__":
    with open(INPUT_PATH, 'r', encoding="utf-8") as file:
        content = file.read()

    result = dcm_out_to_dict(content)

    with open(OUTPUT_PATH, "w+", encoding="utf-8") as file:
        json.dump(result, file, indent=4)
