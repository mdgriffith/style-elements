"""
Reference for Chrome Performance Logging:
https://sites.google.com/a/chromium.org/chromedriver/logging/performance-log

Description of traces
https://www.chromium.org/developers/how-tos/trace-event-profiling-tool/trace-event-reading

Get List of categoires for tracing
got to chrome://tracing
hit record.
Check out the list of categories

Tracing Ecosystem Overview:
https://docs.google.com/document/d/1QADiFe0ss7Ydq-LUNOPpIf6z4KXGuWs_ygxiJxoMZKo/edit#

Trace Event Format
https://docs.google.com/document/d/1CvAClvFfyA5R-PhYUmn5OOQtYMH4h6I0nSsKchNAySU/edit

The Rendering Critical Path
https://www.chromium.org/developers/the-rendering-critical-path


Events that affect different paths in the renderer
https://www.html5rocks.com/en/tutorials/speed/high-performance-animations/

"""

import json
import subprocess
from pprint import pprint
from selenium import webdriver
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from selenium.webdriver.chrome.options import Options
from shutil import copyfile
import time
import os
from os import listdir
from os.path import isfile, join, isdir



# enabled = ','.join([
#     'devtools'
#     , 'devtools.timeline'
#     , 'devtools.timeline.async'
#     , 'disabled-by-default-devtools.timeline'
#     , 'renderer'
#     , 'blink'
#     , 'blink_style'
#     , 'blink.animations'
#     , 'disabled-by-default-renderer.scheduler'
#     , 'disabled-by-default-devtools.timeline.invalidationTracking'
#     , 'disabled-by-default-devtools.timeline.frame'
#     , 'disabled-by-default-devtools.timeline.layers'
#     , 'disabled-by-default-devtools.timeline.stack'
# ])

enabled = "devtools.timeline, disabled-by-default-devtools.timeline, blink.user_timing, blink_style, devtools.timeline.async"


def run_benchmark(url):
    caps = DesiredCapabilities.CHROME
    caps['loggingPrefs'] = {'performance': 'ALL', 'browser': 'ALL'}
    caps['chromeOptions']  = { 
          'args' : [ '--enable-gpu-benchmarking'
                   , '--enable-thread-composting'
                   , '--headless'
                   ]
        , 'perfLoggingPrefs': {'traceCategories': enabled }
            # 'browser,devtools.timeline,devtools,benchmark,devtools.timeline.async,blink,cc,gpu,renderer.scheduler,v8,toplevel'} 
        }

    driver = webdriver.Chrome(desired_capabilities=caps)
    # driver = webdriver.Chrome(desired_capabilities=caps, service_args=["--verbose"])

    # {
    #   'loggingPrefs': { 'performance': 'ALL' },
    #   'chromeOptions': {
    #     "args" : ['--enable-gpu-benchmarking', '--enable-thread-composting'],
    #     "perfLoggingPrefs" : {
    #       "traceCategories": "toplevel,disabled-by-default-devtools.timeline.frame,blink.console,disabled-by-default-devtools.timeline,benchmark"
    #     }
    #   }
    # })

    driver.get(url)

    time.sleep(1)
    return driver

skip = ["KeyedServiceFactory::GetServiceForContext", "FunctionCall", "PrerenderManagerFactory::GetForProfile", "TimerFire", "TimerInstall"]

# verbose = ["BenchmarkInstrumentation::ImplThreadRenderingStats"]
verbose = ["Layout", "UpdateLayoutTree", "Paint", "WebViewImpl::layout"]


def retrieve_logs(driver):
    logs = []
    for entry in driver.get_log('performance'):
        msg = json.loads(entry["message"])
        if msg["message"]["method"].startswith("Network."):
            continue
        entry["message"] = msg
        logs.append(entry)    
    return logs



def format_results(logs):
    """
    Takes a list of unfiltered logs, and aggregates events into the following format

    { gc : Int -- Total amount of GC performed
    , js : Int -- Total amount of time spent executing JS
    , recalc_styles : Int -- total amount of time spent recalculating styles
    , layout : Int
    , layoutLayers : Int
    , paint : Int
    , totalRenderTime : Int
    }

    """

    results = {'layout':[], 'paint':[], 'gc':[], 'recalc_styles':[], 'updateLayerTree':[], 'js':[], 'parse_css': [] }
    running_events = {}
    for log in logs:
      

        message = log['message']['message']
        params = message['params']

        if 'name' in params:
            if params['name'] == 'Layout':

                if params['ph'] == 'B':
                    # Event has begun
                    # store it until it's finished
                    #  Doesn't account for multiple starts on the same thread with no endings
                    # ...but we'll skip that.
                    running_events[('layout', params['tid'])] = message

                elif params['ph'] == 'E':
                    # Event has ended
                    if ('layout', params['tid']) in running_events:
                        started = running_events[('layout', params['tid'])]

                        duration = params['ts'] - started['params']['ts']
                        results['layout'].append(duration)

            elif params['name'] == 'Paint':

                results['paint'].append(params['tdur'])
            
            elif params['name'] == 'UpdateLayerTree':

                results['updateLayerTree'].append(params['tdur'])

            # elif params['name'] == 'EvaluateScript':
            #  Evaluate script isn't the actual running time of 

            #     results['js'].append(params['tdur'])

            # elif params['name'] == 'Document::rebuildLayoutTree':

            #     results['rebuild_layout_tree'].append(params['tdur'])
            
            elif params['name'] == 'CSSParserImpl::parseStyleSheet':

                if params['ph'] == 'B':
                    # Event has begun
                    # store it until it's finished
                    #  Doesn't account for multiple starts on the same thread with no endings
                    # ...but we'll skip that.
                    running_events[('parse_css', params['tid'])] = message

                elif params['ph'] == 'E':
                    # Event has ended
                    if ('parse_css', params['tid']) in running_events:
                        started = running_events[('parse_css', params['tid'])]

                        duration = params['ts'] - started['params']['ts']
                        results['parse_css'].append(duration)
            
            elif params['name'] == 'Document::updateStyle':

                if params['ph'] == 'B':
                    # Event has begun
                    # store it until it's finished
                    #  Doesn't account for multiple starts on the same thread with no endings
                    # ...but we'll skip that.
                    running_events[('recalc_styles', params['tid'])] = message

                elif params['ph'] == 'E':
                    # Event has ended
                    if ('recalc_styles', params['tid']) in running_events:
                        started = running_events[('recalc_styles', params['tid'])]

                        duration = params['ts'] - started['params']['ts']
                        results['recalc_styles'].append(duration)
            
            elif params['name'] == 'FunctionCall':

                if params['ph'] == 'B':
                    # Event has begun
                    # store it until it's finished
                    #  Doesn't account for multiple starts on the same thread with no endings
                    # ...but we'll skip that.
                    running_events[('js', params['tid'])] = message

                elif params['ph'] == 'E':
                    # Event has ended
                    if ('js', params['tid']) in running_events:
                        started = running_events[('js', params['tid'])]

                        duration = params['ts'] - started['params']['ts']
                        results['js'].append(duration)
            elif params['name'] == 'MinorGC':

                if params['ph'] == 'B':
                    # Event has begun
                    # store it until it's finished
                    #  Doesn't account for multiple starts on the same thread with no endings
                    # ...but we'll skip that.
                    running_events[('gc', params['tid'])] = message

                elif params['ph'] == 'E':
                    # Event has ended
                    if ('gc', params['tid']) in running_events:
                        started = running_events[('gc', params['tid'])]

                        duration = params['ts'] - started['params']['ts']
                        amount = started['params']['args']['usedHeapSizeBefore'] - params['args']['usedHeapSizeAfter']

                        results['gc'].append({'duration': duration, 'reclaimed_bytes': amount})


    results['layout'] = sum(results['layout'])
    results['paint'] = sum(results['paint'])
    results['recalc_styles'] = sum(results['recalc_styles'])
    results['updateLayerTree'] = sum(results['updateLayerTree'])
    results['js'] = sum(results['js'])
    results['parse_css'] = sum(results['parse_css'])
    
    results['total_time'] = results['layout'] + results['paint'] + results['recalc_styles'] + results['updateLayerTree'] + results['js'] + results['parse_css']

    return results


def compile(elm_file, scenario, implementation):
    """
    Compile an elm file and return the path to the resulting html
    """
    print("compiling {file}".format(file=elm_file))
    description = scenario + "_" + implementation

    output = join('staging', description.lower() + ".html")
    code = subprocess.call("elm-make {elm_file} --yes --output {output}".format(elm_file=elm_file, output=output), shell=True)
    return (output, scenario, implementation)

def prepare_scenarios(directory):
    compiled_files = []
    cwd = os.getcwd()

    for node in listdir(scenario_directory):
        if isdir(join(scenario_directory, node)):
            concrete_scenario_dir = join(scenario_directory, node)
            for child_node in listdir(concrete_scenario_dir):
                name = join(concrete_scenario_dir, child_node)
                if isfile(name) and name.endswith('.elm'):
                    compiled_files.append(compile(name, node, child_node[:-4]))
                elif name.endswith(".html"):

                    description = node + "_" + child_node[:-5]
                    output = join(cwd , join('staging', description.lower() + ".html"))
                    copyfile(name, output)

                    compiled_files.append((output, node, child_node[:-5]))

    return compiled_files


def by_duration(record):
    if 'tdur' in record['message']['message']['params']:
        return record['message']['message']['params']['tdur']
    else:
        return 0

def sort_logs(logs):
    sorted(student_tuples, key=lambda student: student[2]) 

if __name__ == "__main__":

    cwd = os.getcwd()
    scenario_directory = 'scenarios'
    results = []
    for scenario_url, scenario, implementation in prepare_scenarios(scenario_directory):

        driver = run_benchmark("file://" + join(cwd, scenario_url))
        logs = retrieve_logs(driver)
        results.append({"implementation": implementation, "scenario":scenario, "results":format_results(logs) })

        # results.append({"description": description, "results":sorted(logs, key=by_duration) })
        driver.close()


    # Compile the results viewer
    subprocess.call("elm-make ViewResults.elm --yes --output results/elm.js", shell=True)

    
    with open('view-template.html') as TEMPLATE:
        with open('results/view-results.html', 'w') as RESULTS:
            
            rendered = TEMPLATE.read().format(benchmark_data=json.dumps(results))

            RESULTS.write(rendered)