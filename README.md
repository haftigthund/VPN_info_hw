# Requirement:
## 1. use tap and openssl to develop VPN
## 2. provide two source codes in C
## 3. prepare a tutorial

# Setup:
## 1. use containers to setup two separate network environments
## 2. client:
### 1. create a TAP interface
### 2. establish TLS connection to the gateway
### 3. read the packets from TAP interface and send through TLS tunnel
### 4. receive packets from TLS tunnel and write to TAP interface
## 3. gateway:
### 1. create a TAP interface
### 2. listen for TLS connections from clients
### 3. forward packets between the TLS tunnel and local network
### 4. handle routing between the VPN client and the router

# Issues:
## 1. get familiar with TAP
## 2. setup containers