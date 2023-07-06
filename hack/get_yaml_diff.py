import argparse
import ruamel.yaml
import copy
import sys

def clean_empty(d):
    """Recursively remove all empty lists, empty dicts, or None elements from a dictionary."""
    if not isinstance(d, (dict, list)):
        return d
    if isinstance(d, list):
        return [v for v in (clean_empty(v) for v in d) if v]
    return {k: v for k, v in ((k, clean_empty(v)) for k, v in d.items()) if v}

def merge_dicts(a, b, path=None, diff=None):
    """Merges b into a and returns dictionary with additions and changes"""

    if path is None: path = []
    if diff is None: diff = {}

    for key in b:
        if key in a:
            if isinstance(a[key], dict) and isinstance(b[key], dict):
                if key not in diff:
                    diff[key] = {}
                merge_dicts(a[key], b[key], path + [str(key)], diff[key])
            elif a[key] == b[key]:
                pass # same leaf value
            else:
                #print('Changed in {}: {} -> {}'.format('.'.join(path + [str(key)]), a[key], b[key]))
                a[key] = b[key] # apply changes
                diff[key] = copy.deepcopy(b[key]) # record changes
        else:
            #print('Added {}: {}'.format('.'.join(path + [str(key)]), b[key]))
            a[key] = b[key] # apply additions
            diff[key] = copy.deepcopy(b[key]) # record additions
    return diff

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("yaml1", help="Path to the first yaml file")
    parser.add_argument("yaml2", help="Path to the second yaml file")
    args = parser.parse_args()

    yaml = ruamel.yaml.YAML()

    with open(args.yaml1, 'r') as stream1:
        data1 = yaml.load(stream1)

    with open(args.yaml2, 'r') as stream2:
        data2 = yaml.load(stream2)

    #print('Changes and additions from {} to {}:\n'.format(args.yaml1, args.yaml2))
    diff = merge_dicts(data1, data2)

    #print('\nDifferences in YAML format:\n')
    diff = clean_empty(diff)  # clean the empty keys
    yaml.dump(diff, sys.stdout)

if __name__ == "__main__":
    main()
