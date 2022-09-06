# Infrastructure as Code

Ansible is a radically simple IT automation platform that makes your applications and systems easier to deploy. Avoid writing scripts or custom code to deploy and update your applications— automate in a language that approaches plain English, using SSH, with no agents to install on remote systems.

![img](../images/Screenshot%202022-09-05%20at%2015.27.52.png)

## Configuration Management

### Run commands in Controller VM

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

### Update Hosts

`sudo nano hosts`

```
[web]
192.168.56.10 ansible_connection=ssh ansible_ssh_user=vagrant ansible_ssh_pass=vagrant

[db]
192.168.56.11 ansible_connection=ssh ansible_ssh_user=vagrant ansible_ssh_pass=vagrant

```

`ansible all -m ping`

`ansible web -m ping` `sudo ansible web -m ping`

![img](../images/Screenshot%202022-09-06%20at%2009.21.16.png)

### Ad-Hocs commands

- `ansible web -a "uname -a"`
- `ansible all -a "uname -a"`
- `ansible all -a "ls"`
- `ansible web -a "pwd"`
- `ansible web -a "free"`
- `ansible web -a "date"`
- `ansible all -a "date"`
- `ansible all -a "systemctl status nginx"`
- `ansible web -m shell -a "uptime"`
- Command to copy a test file from etc/ansible to vagrant: `ansible web -m copy -a "src=/etc/ansible/test.txt dest=/home/vagrant"`

### Create Playbook

- `sudo nano playbook-name.yml`
- Add the script

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

- Run command: `ansible-playbook playbookname-playbook.yml`
- To check the status: `sudo ansible web -a "systemctl status nginx"`

## Connect to DB

`ssh vagrant@192.168.56.11`

`sudo apt-get update -y`

`sudo apt-get upgrade -y`

`exit`

````
# This playbook is to configure mongodb in our db server
---
# host name
- hosts: db

  gather_facts: yes

# admin access
  become: yes

# Add set of instructions
  tasks:
  - name: set up Mongodb in db server
    apt: pkg=mongodb state=present

  - name: Remove mongodb file(delete file)
    file:
      path: /etc/mongodb.conf
      state: absent

  - name: Touch a file, using symbolic modes to set the permissions
    file:
      path: /etc/mongodb.conf
      state: touch
      mode: u=rw,g=r,o=r
      #g for group o for any other user

  - name: Insert multiple lines and Backup
    blockinfile:
      path: /etc/mongodb.conf
      backup: yes
      block: |
        "storage:
          dbPath: /var/lib/mongodb
          journal:
            enabled: true
        systemLog:
          destination: file
          logAppend: true
          path: /var/log/mongodb/mongod.log
        net:
          port: 27017
          bindIp: 0.0.0.0"

    ```
````

`ansible-playbook mongo-playbook.yml --syntax-check`

`ansible-playbook mongo-playbook.yml`
