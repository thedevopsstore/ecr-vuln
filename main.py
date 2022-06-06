import yaml

import os
import sys


from jinja2 import Environment, FileSystemLoader

app_env = sys.argv[1]

path=os.path.join(app_env, 'value.yaml')


values = yaml.load(open(path))

# Load templates file from templtes folder

env = Environment(loader = FileSystemLoader('./templates'),   trim_blocks=True, lstrip_blocks=True)

template = env.get_template('manifest.j2')

for service in values["services"]:
  file=open("deploy-"+service['name']+"-"+service['env']+".yaml", "w")
  file.write(template.render(service))
  file.close()
