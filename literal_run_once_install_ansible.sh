#!/bin/bash

ansible-playbook ~/.bootstrap/setup.yml --ask-become-pass

echo "Ansible installation complete."
