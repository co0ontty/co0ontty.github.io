eval "lint-md _posts --config .lint-md.json"
if [ $? -ne 0 ]; then
    echo "failed"
    eval "lint-md _posts --config .lint-md.json --fix"
else
    echo "succeed"
fi
