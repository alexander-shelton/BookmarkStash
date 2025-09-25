#!/usr/bin/env sh
#
# test-floating-fzf.sh - Test script for debugging floating fzf
#

# Test data
echo "option1
option2
option3
option4
option5" > /tmp/test_data

echo "Testing floating fzf..."

# Test 1: Direct fzf call (should work in regular terminal)
echo "Test 1: Regular fzf"
selection=$(cat /tmp/test_data | fzf --prompt="Test> ")
echo "Selected: $selection"

# Test 2: footclient with direct fzf
echo "Test 2: footclient direct"
selection=$(cat /tmp/test_data | footclient --app-id floating_shell --window-size-chars 82x25 -- fzf --prompt="Test Direct> ")
echo "Selected: $selection"

# Test 3: footclient with sh -c
echo "Test 3: footclient with sh -c"
selection=$(cat /tmp/test_data | footclient --app-id floating_shell --window-size-chars 82x25 -- sh -c 'fzf --prompt="Test sh -c> "')
echo "Selected: $selection"

# Test 4: footclient with wrapper script
echo "Test 4: footclient with wrapper script"
cat > /tmp/fzf_wrapper << 'EOF'
#!/usr/bin/env sh
exec fzf --prompt="Test Wrapper> " "$@"
EOF
chmod +x /tmp/fzf_wrapper

selection=$(cat /tmp/test_data | footclient --app-id floating_shell --window-size-chars 82x25 -- /tmp/fzf_wrapper)
echo "Selected: $selection"

# Clean up
rm -f /tmp/test_data /tmp/fzf_wrapper

echo "Tests complete!"