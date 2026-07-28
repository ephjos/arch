#!/bin/sh
#


config_file="https://raw.githubusercontent.com/ephjos/arch/refs/heads/main/archinstall_config.json"

while [ $# -gt 0 ]; do
    case "$1" in
        --dev)
            config_file="http://10.0.2.2:8000/archinstall_config.json"
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo
            echo "Options:"
            echo "  --dev        Pull install files from local"
            echo "  -h, --help   Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Try '$0 --help' for usage."
            exit 1
            ;;
    esac
    shift
done

archinstall --config-url "$config_file" < /dev/tty
