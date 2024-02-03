# Python

- variables: containers for storing values
  - when naming variables, do not use keywords.
    - reserved words (keywords) are defined with predefined meaning and syntax in the language <https://realpython.com/python-keywords/#:~:text=Python%20keywords%20are%20special%20reserved,import%20them%20into%20your%20code.>
      - these are used to develop programming instructions and cannot be used as identifies for other programming elements like the name of a varibale, function, etc.

```python key words

- >>> help("keywords")

Here is a list of the Python keywords.  Enter any keyword to get more help.

False               class               from                or
None                continue            global              pass
True                def                 if                  raise
and                 del                 import              return
as                  elif                in                  try
assert              else                is                  while
async               except              lambda              with
await               finally             nonlocal            yield
break               for                 not
```

- functions: block of code or lofic in code that helps to avoid repeating the same logic
  - a function is defined using the def keyword
  - it only runs when invoked/called
- parameters: information that can be passed into functions as parameters
  - parameters are also called arguments
- scope: a variable is only available from inside the region it is created
  - global scope: global variables are available from within any scope
  - local scope: local variables are created inside a function
    - can only be used inside that function
- input(): to ask the user for an input
  - python stops executing when it comes to the input()
  - always returns a string
- expression: an instruction that combines values and operators and always evaluates down to a single value
- return values: a function can return data as a result
- casting: process of turning a value of one data type into another. eg. int. into str. ...etc
  - str(56): turns value into string
  - int(): built-in py function
    - converts the specified value into an integer
- conditionals: expressions that evaluate to either true of false

  ```conditional
  if condition is correct:
    then do this
  else:
    do this
    ```

- boolean data type can only be True or False

- comparison operators
  - equals: `a == b`
  - not equals: `a != b`
  - less than: `a < b`
  - less than or equal to: `a <= b`
  - greater than: `a > b`
  - greater than or equal to: `a >= b`

- arithmetic operators:
  - addition: `x + y`
  - subtraction: `x - y`
  - multiplication: `x * y`
  - division: `x / y`
  - modulus: `x % y`
  - exponentiation: `x ** y`
  - floor division: `x // y`

- return value of inner function is the input value for the outer function.
  - eg. `num_mins = days_to_units(int(user_input))`
- try/except:
  - the try block: lets you "test" a block of code for errors
  - the except block: catched the error and lets you handle it
  - also called "try/catch" in other programming languages
- Looping:
  - to execute logic multiple times
  - python has 2 loop commands:
    - while loop:
      - execute a set of statements as long as a conditiion is true
      - for loops:
        - used for iterationg over a sequence (like a list)
- lists: used to store multiple items in a single variable
  - syntax: `[]`
  - a list can contain different data types
  - to add to list: `list.append("item_to_append")`
  - you can remove from a list with `my_list.remove("item_to_remove")`
- string - `split()`
  - The split() method is the most common way to split a string into a list in Python.
  - it splits a string into substrings based on a delimiter and returns a list of these substrings.
  - e.g., split the string "Hello world" into a list of two elements, "Hello" and "world" , using the split() method.
  - default separator is any white space
  - to tell the method to separate on a comma: `split(",")`
  - to tell the method to separate on a comma and space: `split(", ")`
- set <https://www.w3schools.com/python/python_sets.asp>
  - built-in data type
  - used to store multiple items of data
  - a set is a collection which is unordered, unchangeable (only added or removed) and unindexed
  - syntax: `{}`
  - you can add to a set with `my_set.add("item_to_add")`
  - you can remove from a set with `my_set.remove("item_to_remove")`
- nested function execution: from innermost to outermost
  - `print(type(set(list_of_days)))`
    - `set(list_of_days)`:
      - input: the user input array
      - output: returns the converted set
    - `type(return_value_of_previous_func)`:
      - input: the converted set
      - output: returns the data type of the set
    - `print(return_value_of_previous_func)`:
      - input: the data type
      - output: prints the value to the console
- built-in functions: <https://docs.python.org/3/library/functions.html>
  - each data type has its own built-in functions which are useful/make sense only for this specific data type
- dictionary:
  - used to store values in key:value pairs
  - is a collection, which does not allow duplicate values
  - items can be access by index
  - accessing items in a dictionary:
    - items can be accessed by its key name
    - you can use square brackets or get() method
    - my_dict = {"days": 20, "unit": "hours", "message": "OK!"}
      - `my_dict["days"]` or `my_dict.get("days")`
- modules:
  - logically orgaznize python code.
  - a module should contain related code
  - a module is a file with function, variables, or other code logic that you can access from another file
  - things that are defined in a module that can be used in another file are called *definitions*
  - import helper:

    ```import module
    import helper
    # use:
    helper.validate_and_execute(list_of_days_dictionary)
    ```

  - import abc as xyz: renames the module:

    ```rename module
    import helper as help - renames the module into help...
    # use:
    help.validate_and_execute(list_of_days_dictionary)
    ```

- built-in vs. third party
  - python only comes with a set of built-in modules
  - if the modules you need are not part of the python installation, you need to install these third-party packages.
  - python modules live in a module repo called __PyPi__ <https://pypi.org/>
    - people can publish their packages to this repo and make it available for everyone to use
  - module vs. package:<https://realpython.com/lessons/scripts-modules-packages-and-libraries/#:~:text=Modules%20are%20Python%20files%20that,to%20achieve%20a%20common%20goal.>
    - Modules are Python files that are intended to be imported into scripts and other modules so that their defined members—like classes and functions—can be used.
      - .py file
    - Packages are a collection of related modules that aim to achieve a common goal.
      - package must include an `__init__.py` file which distinguishes a package from a directory
      - we install python packages using a package manager called __pip__
        - used to install external python packages or libraries also called dependencies from the Python Package Index(PyPi), and other indexes
        - in python3, pip is included in the python installation
    - Library: collection of packages

- project: automation with python
  - different ways to work with files
    - python has several built-in functions for handling files
      - `io module`: create, read, write
    - external package to work with spreadsheets specifically: `openpyxl`
  - range(): creates a sequence of numbers starting from 0 by default

- OOP: Classes and Objects: <https://www.programiz.com/python-programming/class#:~:text=We%20know%20that%20Python%20also,a%20blueprint%20for%20that%20object.>
  - Object: An object is simply a collection of data (variables) and methods (functions) into a single entity
    - objects get their variables and functions from classes
  - Class: class is a blueprint for that object.
    - classes are essentially a template to create your objects/ object constructor
    - all classes have an `__init__()` function
    - `__init__()` is executed automatically, whenever we create the objects from this class
    - `self` parameter
      - `self` is a reference to the current instance of the class
      - it is used to access variables that belong to the class
  - Methods: functions that belong to an object are called methods

- json():
  - a lightweight format for transporting data
  - often used to send data over the web
  - requests json() function converts the data from json into python data type
