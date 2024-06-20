#!/bin/bash

# Array of VM names
vms=("GOAD-DC01" "GOAD-DC02" "GOAD-DC03" "GOAD-SRV02" "GOAD-SRV03")

# Function to check if a VM exists
vm_exists() {
  vboxmanage list vms | grep -q "\"$1\""
}

# Function to start a VM in the background
start_vm() {
  if vm_exists "$1"; then
    echo "Starting existing VM: $1"
    vboxmanage startvm "$1" --type headless
  else
    echo "Creating and starting new VM: $1"
    vagrant up "$1" --provider=virtualbox
  fi
}

# Function to stop a VM
stop_vm() {
  if vm_exists "$1"; then
    echo "Stopping VM: $1"
    vboxmanage controlvm "$1" acpipowerbutton
  else
    echo "VM $1 does not exist."
  fi
}

# Function to start all VMs
start_all_vms() {
  cd ad/GOAD/providers/virtualbox || { echo "Directory not found"; exit 1; }
  for vm in "${vms[@]}"; do
    start_vm "$vm" &
  done
  wait
  echo "All VMs are started."
}

# Function to stop all VMs
stop_all_vms() {
  for vm in "${vms[@]}"; do
    stop_vm "$vm" &
  done
  wait
  echo "All VMs are stopped."
}

# Check for user input
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 {start|stop}"
  exit 1
fi

# Perform action based on user input
case "$1" in
  start)
    start_all_vms
    ;;
  stop)
    stop_all_vms
    ;;
  *)
    echo "Invalid option: $1"
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac
