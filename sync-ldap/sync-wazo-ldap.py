#!/usr/bin/python3
# coding: utf-8

import configparser
import uuid
import wazo_auth_client
import wazo_confd_client
import requests
from ldap3 import Server, Connection, SUBTREE
from requests.exceptions import HTTPError

config = configparser.ConfigParser()
config.read('config.ini')

subscription_type = config['wazo']['subscription_type']
attr_given_name = config['ldap']['given_name']
attr_last_name = config['ldap']['last_name']
attr_email = config['ldap']['email']
attr_identifier = config['ldap']['identifier']
attr_extension = config['ldap']['extension']
attr_incall = config['ldap']['incall']


def get_users():
    try:
        global wazo_users
        global wazo_auth_users
        wazo_users = wazo_client.users.list()['items']
        wazo_auth_users = auth_client.users.list()['items']
    except Exception as error:
        print(error)


def create_user(ldap_user):
    u = {}
    u['firstname'] = ldap_user[attr_given_name][0]
    u['lastname'] = ldap_user[attr_last_name][0]
    u['email'] = ldap_user[attr_email][0]
    u['tenant_uuid'] = config['wazo']['tenant']
    u['subscription_type'] = subscription_type
    u['auth'] = {
        'email_address': ldap_user[attr_email][0],
        'firstname': ldap_user[attr_given_name][0],
        'lastname': ldap_user[attr_last_name][0],
        'purpose': 'user',
        'username': ldap_user[attr_identifier][0]
    }
    u['username'] = ldap_user[attr_identifier][0]
    u['lines'] = []
    if attr_extension in ldap_user and config['wazo']['context_name'] and config['wazo']['endpoint_sip_template_uuid']:
        nane_sip = str(uuid.uuid4())
        u['lines'].append({
            'context': config['wazo']['context_name'],
            'caller_id_name': ldap_user[attr_given_name][0] + ' ' + ldap_user[attr_last_name][0],
            'caller_id_num': ldap_user[attr_extension][0],
            'extensions': [{'context': config['wazo']['context_name'], 'exten': ldap_user[attr_extension][0]}],
            'endpoint_sip': {
                'templates': [
                    {'uuid': config['wazo']['endpoint_sip_template_uuid']}
                ],
                'name': nane_sip,
                'auth_section_options': [
                    ['username', nane_sip],
                    ['password', str(uuid.uuid4())]
                ]
            }
        })
        if config['wazo']['endpoint_sip_template_uuid_webrtc']:
            name_webrtc = str(uuid.uuid4())
            u['lines'].append({
                'context': config['wazo']['context_name'],
                'caller_id_name': ldap_user[attr_given_name][0] + ' ' + ldap_user[attr_last_name][0],
                'caller_id_num': ldap_user[attr_extension][0],
                'extensions': [{'context': config['wazo']['context_name'], 'exten': ldap_user[attr_extension][0]}],
                'endpoint_sip': {
                    'templates': [
                        {'uuid': config['wazo']['endpoint_sip_template_uuid']},
                        {'uuid': config['wazo']['endpoint_sip_template_uuid_webrtc']}
                    ],
                    'name': name_webrtc,
                    'auth_section_options': [
                        ['username', name_webrtc],
                        ['password', str(uuid.uuid4())]
                    ]
                }
            })
    try:
        wu = wazo_client.users.create(u)
        create_sda(ldap_user, wu)
    except HTTPError as error:
        print(error)


def delete_user(wazo_user):
    u = wazo_client.users.get(wazo_user['uuid'])
    url = ('https' if wazo_client._https else 'http') + '://' + wazo_client.host + wazo_client._prefix + '/' + wazo_client._version + '/users/' + str(u['id'])
    requests.delete(url, headers={'X-Auth-Token': auth_token['token']}, params={'recursive': True})
    if 'lines' in u:
        for line in u['lines']:
            if 'extensions' in line:
                for extension in line['extensions']:
                    try:
                        wazo_client.extensions.delete(extension['id'])
                    except Exception as error:
                        print(error)
    if 'incalls' in u:
        for incall in u['incalls']:
            if 'extensions' in incall:
                for extension in incall['extensions']:
                    try:
                        wazo_client.extensions.delete(extension['id'])
                    except Exception as error:
                        print(error)


def create_sda(ldap_user, wazo_user):
    if attr_incall not in ldap_user or len(ldap_user[attr_incall]) == 0:
        return
    incall = None
    try:
        i = {
            'destination': {
                'type': 'user',
                'user_id': wazo_user['id']
            }
        }
        incall = wazo_client.incalls.create(i)
    except Exception as error:
        print(error)
    try:
        e = {
            'context': config['wazo']['context_sda_name'],
            'exten': ldap_user[attr_incall][0]
        }
        extension = wazo_client.extensions.create(e)
        if incall and extension:
            try:
                wazo_client.incalls.relations(incall['id']).add_extension(extension['id'])
            except Exception as error:
                print(error)
    except Exception as error:
        print(error)


wazo_users = []
wazo_auth_users = []

# Init client auth
auth_client = wazo_auth_client.Client(config['wazo']['host'], username=config['wazo']['username'], password=config['wazo']['password'])
auth_token = auth_client.token.new('wazo_user', expiration=60)
auth_client.set_token(auth_token['token'])

# Init client confd
wazo_client = wazo_confd_client.Client(config['wazo']['host'], token=auth_token['token'])

# Get Wazo users
get_users()

# Get LDAP users
ldap = Server(config['ldap']['url'], port=config.getint('ldap', 'port'), use_ssl=config.getboolean('ldap', 'use_ssl'))

connection_ldap = Connection(ldap, user=config['ldap']['user'], password=config['ldap']['password'])
connection_ldap.bind()

connection_ldap.search(search_base=config['ldap']['search_base'],
                       search_filter=config['ldap']['search_filter'],
                       search_scope=SUBTREE,
                       attributes=[attr_email, attr_given_name, attr_last_name, attr_identifier, attr_extension, attr_incall])

# Sync LDAP and Wazo users
# LDAP -> Wazo
for entry in connection_ldap.response:
    is_wazo_user = False
    for wazo_user in wazo_users:
        if wazo_user['email'] == entry['attributes'][attr_email][0] and not is_wazo_user:
            is_wazo_user = True
            break
    # Add LDAP user to Wazo
    if not is_wazo_user:
        create_user(entry['attributes'])

# Wazo -> LDAP
for wazo_user in wazo_users:
    in_ldap = False
    for entry in connection_ldap.response:
        if wazo_user['email'] == entry['attributes'][attr_email][0]:
            in_ldap = True
    # Remove Wazo user not in LDAP
    if not in_ldap:
        delete_user(wazo_user)

connection_ldap.unbind()
