# Infrastructure as Code

Ansible is a radically simple IT automation platform that makes your applications and systems easier to deploy. Avoid writing scripts or custom code to deploy and update your applications— automate in a language that approaches plain English, using SSH, with no agents to install on remote systems.

![img](../images/Screenshot%202022-09-05%20at%2015.27.52.png)

## Run commands

`sudo apt-get install software-properties-common`

`sudo apt-add-repository ppa:ansible/ansible`

`sudo apt-get update -y`

`sudo apt-get install ansible -y`

`ansible --version`

Default directory : `cd /etc/ansible/`

`sudo apt install tree`

`tree`

`ping 192.168.56.10`

`ssh vagrant@192.168.56.10` say yes --> password: `vagrant`

`sudo apt-get update -y`

`sudo apt-get upgrade -y`

`exit`

`ssh vagrant@192.168.56.11` say yes --> password: `vagrant`

`sudo apt-get update -y`

`sudo apt-get upgrade -y`

```
# Create a playbook to install nginx web server inside web
# --- three dashes at the start of the file of YML

---

# Add hosts or name of the host server
- hosts: web

# Intendation is EXTREMELY IMPORTANT
# Gather live information
  gather_facts: yes

# We need admin access
  become: true

# Add the instructions
#install nginx in web server
  tasks:
  - name: Install Nginx
    apt: pkg=nginx state=present


# The nginx server status is running
```
