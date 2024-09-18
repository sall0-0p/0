local function exampleFunction()
    print(debug.getinfo(1).func == exampleFunction);
end

exampleFunction();