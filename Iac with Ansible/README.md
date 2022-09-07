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

# Install dependencies

`sudo nano node-playbook.ym`

```
# Install node.js and npm

---

# Add hosts or name of the host server

- hosts: web

# Gather live information
  gather_facts: yes

# Admin access
  become: true

# Add instructions
  tasks:
  - name: Install nodejs
    apt: pkg=nodejs state=present

  - name: Install NPM
    apt: pkg=npm state=present

#  - name: Latest NPM
#    shell: |
#      npm install -g npm@7

#  - name: Install pm2
#    npm:
#      name: pm2
#      global: yes

#  - name: run app
#    shell: |
#      cd app
#      npm install
#      nohup node app.js > /dev/null 2>&1 &

```

`ansible-playbook node-playbook.yml`

### Configure reverse proxy

`sudo nano default`

```
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;


        index index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {
                proxy_pass http://localhost:3000;
        }
}
```

`sudo nano reverseproxy-playbook.yml`

```# create a playbook to configure the reverse proxy inside web

---

# Add host name
- hosts: web

# Gather live information
  gather_facts: yes

# Admin access
  become: yes

# Add the instructions
  tasks:
  - name: Configure reverse proxy
    copy:
        src: /etc/ansible/default
        dest: /etc/nginx/sites-available/default

# Reverse proxy should be set up

```

## Transfer app to vagrant

```
---
- name: transfer code for app from controller to the web instance
  hosts: web
  tasks:
  - name: download the files for the nodeapp
    become: true
    copy:
      src: /home/vagrant/monolithic_architecture/app
      dest: /home/vagrant/app

```

## Creating a service to launch node app

```
- name: creating service for the nodeapp to run on
  hosts: web
  tasks:
  - name: Create nodeapp service file
    become: yes
    file:
      path: /etc/systemd/system/nodeapp.service
      state: touch

  - name: Amend nodeapp service file
    become: yes
    blockinfile:
      path: /etc/systemd/system/nodeapp.service
      marker: ""
      block: |
        [Unit]
        Description=Launch Node App

        [Service]
        Type=simple
        Restart=always
        user=root
        ExecStart=/usr/bin/nodeapp.sh

        [Install]
        WantedBy=multi-user.target

```

## Transfer Provision script from controller to web

```
---
- name: transfer prov script from controller to web
  hosts: web
  tasks:
  - name: download prov script
    become: true
    copy:
      src: /etc/ansible/nodeapp.sh
      dest: /usr/bin/nodeapp.sh

```

## Launch the app

```
---
- name: launch the node app
  hosts: web
  become: true
  tasks:
    - name: make shell executable
      shell: chmod +x /usr/bin/nodeapp.sh

    - name: enable new service
      shell: sudo systemctl daemon-reload

    - name: enable nodeapp service
      shell: sudo systemctl enable nodeapp.service

    - name: start nodeapp service
      shell: sudo systemctl start nodeapp.service

    - name: check status
      shell : sudo systemctl status nodeapp.service

```

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

## Playbook to create ec2 instance

````
---

- hosts: localhost
  connection: local
  gather_facts: False

  vars:
    ansible_python_interpreter: /usr/bin/python3
    key_name: eng122
    region: eu-west-1
    image: ami-09d1b85ba67d3f51a # https://cloud-images.ubuntu.com/locator/ec2/
    id: "fatema-ec2-web-app"
    sec_group: "{{ id }}-sec"

  tasks:

    - name: Facts
      block:

      - name: Get instances facts
        ec2_instance_facts:
          aws_access_key: "{{aws_access_key}}"
          aws_secret_key: "{{aws_secret_key}}"
          region: "{{region}}"
        register: result

      - name: Instances ID
        debug:
          msg: "ID: {{ item.instance_id }} - State: {{ item.state.name }} - Public DNS: {{ item.public_dns_name }}"
        loop: "{{ result.instances }}"

      tags: always


    - name: Provisioning EC2 instances
      block:

      - name: Upload public key to AWS
        ec2_key:
          name: "{{ key_name }}"
          key_material: "{{ lookup('file', '/home/vagrant/.ssh/{{ key_name }}.pub') }}"
          region: "{{ region }}"
          aws_access_key: "{{aws_access_key}}"
          aws_secret_key: "{{aws_secret_key}}"

      - name: Create security group
        ec2_group:
          name: "{{ sec_group }}"
          description: "Sec group for app {{ id }}"
          # vpc_id: 12345
          region: "{{ region }}"
          aws_access_key: "{{aws_access_key}}"
          aws_secret_key: "{{aws_secret_key}}"
          rules:
            - proto: tcp
              ports:
                - 22
              cidr_ip: 0.0.0.0/0
              rule_desc: allow all on ssh port
        register: result_sec_group

      - name: Provision instance(s)
        ec2:
          aws_access_key: "{{aws_access_key}}"
          aws_secret_key: "{{aws_secret_key}}"
          key_name: "{{ key_name }}"
          id: "{{ id }}"
          group_id: "{{ result_sec_group.group_id }}"
          image: "{{ image }}"
          instance_type: t2.micro
          region: "{{ region }}"
          wait: true
          count: 1
          # exact_count: 2
          count_tag:
            Name: eng122-fatema-ansible
          instance_tags:
            Name: eng122-fatema-ansible

      tags: ['never', 'create_ec2']

      ```
````
