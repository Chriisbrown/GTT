import sys
from subprocess import call
import yaml
from optparse import OptionParser
import os

if __name__ == "__main__":
  parser = OptionParser()
  parser.add_option('-c', '--config', action='store', type='string', dest='config', default='project_config.yml', help='Project setup configuration file')
  (options, args) = parser.parse_args()

  yamlConfig = yaml.load(open(options.config, 'r'))
  os.chdir(yamlConfig['p2-xware'])

  call(["ipbb", "proj", "create", "sim", "{}".format(yamlConfig['ProjName']), "/home/hep/cb719/EMP/alt-work/src/GTTtop:", yamlConfig['depfile']])
  os.chdir('proj/{}'.format(yamlConfig['ProjName']))
