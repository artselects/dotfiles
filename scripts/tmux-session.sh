#!/usr/bin/env bash

# Generic tmux Session Manager
# Usage: t-session [session-name]

SESSION_NAME="${1:-default}"

# Helper functions
print_quick_ref() {
    echo "----------------------------------------------"
    echo " tmux Quick Reference"
    echo "----------------------------------------------"
    echo ""
    echo " MOUSE:"
    echo "   Prefix + m        Toggle mouse support"
    echo "   Long-press        Select / Copy / Paste"
    echo ""
    echo " KEYBOARD:"
    echo "   Prefix + c        New window"
    echo "   Prefix + | / -    Split pane"
    echo "   Prefix + r        Reload config"
    echo "----------------------------------------------"
}

case "$1" in
    "help"|"-h"|"--help")
        echo "Usage:"
        echo "  t-session                    # Connect to 'default' session"
        echo "  t-session <session-name>     # Connect to named session"
        echo "  t-session ls                # List all sessions"
        echo "  t-session kill <session>    # Kill a session"
        exit 0
        ;;
    "list"|"ls")
        tmux list-sessions 2>/dev/null || echo "No active sessions"
        exit 0
        ;;
    "kill")
        if [ -z "$2" ]; then
            echo "❌ Please specify session name to kill"
            exit 1
        fi
        tmux kill-session -t "$2"
        exit 0
        ;;
esac

# Check if the specific session exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Reconnecting to session: $SESSION_NAME"
    print_quick_ref
    tmux attach-session -t "$SESSION_NAME"
else
    echo "Creating new session: $SESSION_NAME"
    print_quick_ref
    # Create new session with current home path
    tmux new-session -d -s "$SESSION_NAME" -c "$HOME"
    tmux attach-session -t "$SESSION_NAME"
fi
