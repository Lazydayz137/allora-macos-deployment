#!/bin/bash

# Allora Node Service Management Script for macOS
# This script provides systemd-like functionality using launchd

VALIDATOR_PLIST="$HOME/Library/LaunchAgents/com.allora.validator.plist"
WORKER_PLIST="$HOME/Library/LaunchAgents/com.allora.worker.plist"
LOG_DIR="$HOME/Library/Logs"

show_usage() {
    echo "🚀 Allora Node Service Management for macOS"
    echo "===========================================" 
    echo "Usage: $0 {start|stop|restart|status|logs} {validator|worker|all}"
    echo ""
    echo "Commands:"
    echo "  start     - Start the specified service(s)"
    echo "  stop      - Stop the specified service(s)"
    echo "  restart   - Restart the specified service(s)"
    echo "  status    - Show status of the specified service(s)"
    echo "  logs      - Show logs for the specified service(s)"
    echo ""
    echo "Services:"
    echo "  validator - Allora validator node"
    echo "  worker    - Allora worker node"
    echo "  all       - Both validator and worker nodes"
    echo ""
    echo "Examples:"
    echo "  $0 start validator"
    echo "  $0 status all"
    echo "  $0 logs worker"
    echo "  $0 restart all"
}

manage_service() {
    local action=$1
    local service=$2
    local plist_file=""
    local service_name=""
    
    case $service in
        "validator")
            plist_file="$VALIDATOR_PLIST"
            service_name="com.allora.validator"
            ;;
        "worker")
            plist_file="$WORKER_PLIST"
            service_name="com.allora.worker"
            ;;
        *)
            echo "❌ Invalid service: $service"
            return 1
            ;;
    esac
    
    case $action in
        "start")
            echo "🚀 Starting $service service..."
            if [ -f "$plist_file" ]; then
                launchctl load "$plist_file" 2>/dev/null
                echo "✅ $service service started"
            else
                echo "❌ Error: $plist_file not found. Please run the installation playbook first."
                return 1
            fi
            ;;
        "stop")
            echo "🛑 Stopping $service service..."
            launchctl unload "$plist_file" 2>/dev/null
            echo "✅ $service service stopped"
            ;;
        "restart")
            echo "🔄 Restarting $service service..."
            launchctl unload "$plist_file" 2>/dev/null
            sleep 2
            if [ -f "$plist_file" ]; then
                launchctl load "$plist_file" 2>/dev/null
                echo "✅ $service service restarted"
            else
                echo "❌ Error: $plist_file not found."
                return 1
            fi
            ;;
        "status")
            echo "📊 Status for $service service:"
            if launchctl list | grep -q "$service_name"; then
                echo "✅ $service service is running"
                launchctl list | grep "$service_name"
            else
                echo "❌ $service service is not running"
            fi
            ;;
        "logs")
            case $service in
                "validator")
                    echo "📄 === Validator Logs (stdout) ==="
                    if [ -f "$LOG_DIR/allora-validator.log" ]; then
                        tail -n 20 "$LOG_DIR/allora-validator.log"
                    else
                        echo "No stdout logs found"
                    fi
                    echo ""
                    echo "🚨 === Validator Errors (stderr) ==="
                    if [ -f "$LOG_DIR/allora-validator-error.log" ]; then
                        tail -n 20 "$LOG_DIR/allora-validator-error.log"
                    else
                        echo "No error logs found"
                    fi
                    ;;
                "worker")
                    echo "📄 === Worker Logs (stdout) ==="
                    if [ -f "$LOG_DIR/allora-worker.log" ]; then
                        tail -n 20 "$LOG_DIR/allora-worker.log"
                    else
                        echo "No stdout logs found"
                    fi
                    echo ""
                    echo "🚨 === Worker Errors (stderr) ==="
                    if [ -f "$LOG_DIR/allora-worker-error.log" ]; then
                        tail -n 20 "$LOG_DIR/allora-worker-error.log"
                    else
                        echo "No error logs found"
                    fi
                    ;;
            esac
            ;;
    esac
}

# Main script logic
if [ $# -lt 2 ]; then
    show_usage
    exit 1
fi

ACTION=$1
SERVICE=$2

case $SERVICE in
    "all")
        echo "🔧 Managing all Allora services..."
        manage_service "$ACTION" "validator"
        echo ""
        manage_service "$ACTION" "worker"
        ;;
    "validator"|"worker")
        manage_service "$ACTION" "$SERVICE"
        ;;
    *)
        echo "❌ Invalid service: $SERVICE"
        show_usage
        exit 1
        ;;
esac

echo ""
echo "✨ Operation completed!"
