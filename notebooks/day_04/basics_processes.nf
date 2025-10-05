params.step = 0
params.zip = 'zip'

// Process task 1
process hello {
    debug true
    // This output makes a file and is copied from the website
    output:
    path 'hello.txt'

    script:
    """
    echo 'Hello world!' > hello.txt
    """
}
process hello2 {
    debug true
    // This way the output is printed to the console
    output:
    stdout

    script:
    """
    echo "Hello world!"
    """
}

// Process task 2
process SAYHELLO_PYTHON{
    debug true

    output: 
    stdout

    script:
    """
    python -c "print('Hello World!')"
    """
    // Alternative: 
    // #!/usr/bin/env python
    // print("Hello World")
}

// Process task 3
process SAYHELLO_PARAM{
    debug true

    input: 
    val world

    output:
    stdout

    script: 
    """
    echo "$world"
    """

}

// Process task 4
process SAYHELLO_FILE{
    debug true

    input: 
    val world

    output: 
    path 'hello.txt'

    script:
    """
    echo '$world' > 'hello.txt'
    """
}

// Process task 5
process UPPERCASE{
    debug true

    input:
    val world

    output:
    path 'HELLO.txt'

    script:
    """
    echo "$world" | tr '[:lower:]' '[:upper:]' > HELLO.txt
    """

}

// Process task 6
process PRINTUPPER{
    debug true

    input:
    path world

    output:
    stdout

    script:
    """
    cat $world
    """
}

// Process task 7
process ZIPPER{
    debug true

    input:
    path world
    val zip

    output:
    path 'HELLO.*'

    script: 
    if (zip == 'zip')
        """
        zip HELLO.zip $world
        """
    else if (zip == 'gzip')
        """
        gzip -c $world> HELLO.txt.gz
        """
    else if (zip == 'bzip2')
        """
        bzip2 -c $world > HELLO.txt.bz2
        """
    else
        error "Unknown compression method: $zip"
}

// Process task 8
process ZIPPER_ALL{
    debug true

    input:
    path world

    output:
    path 'HELLO.*'

    script: 
    """
    zip HELLO.zip $world
    gzip -c $world> HELLO.txt.gz
    bzip2 -c $world > HELLO.txt.bz2
    """
}

process WRITETOFILE{
    debug true

    input:
    val entry

    output:
    path "results/names.tsv"

    script:
    """
    mkdir -p results
    echo -e "name\ttitle" > results/names.tsv
    for row in ${entry.collect {it.name + ":" + it.title }.join(" ") }; do
        name=\${row%%:*}
        title=\${row##*:}
        echo -e "\$name\t\$title" >> results/names.tsv
    done
    """
}

workflow {

    // Task 1 - create a process that says Hello World! (add debug true to the process right after initializing to be sable to print the output to the console)
    if (params.step == 1) {
        hello2()
    }

    // Task 2 - create a process that says Hello World! using Python
    if (params.step == 2) {
        SAYHELLO_PYTHON()
    }

    // Task 3 - create a process that reads in the string "Hello world!" from a channel and write it to command line
    if (params.step == 3) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_PARAM(greeting_ch)
    }

    // Task 4 - create a process that reads in the string "Hello world!" from a channel and write it to a file. WHERE CAN YOU FIND THE FILE?
    if (params.step == 4) {
        greeting_ch = Channel.of("Hello world!")
        SAYHELLO_FILE(greeting_ch)
    }

    // Task 5 - create a process that reads in a string and converts it to uppercase and saves it to a file as output. View the path to the file in the console
    if (params.step == 5) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        out_ch.view()
    }

    // Task 6 - add another process that reads in the resulting file from UPPERCASE and print the content to the console (debug true). WHAT CHANGED IN THE OUTPUT?
    if (params.step == 6) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        PRINTUPPER(out_ch)
    }

    
    // Task 7 - based on the paramater "zip" (see at the head of the file), create a process that zips the file created in the UPPERCASE process either in "zip", "gzip" OR "bzip2" format.
    //          Print out the path to the zipped file in the console
    if (params.step == 7) {
        greeting_ch = Channel.of("Hello world!")
        out_ch = UPPERCASE(greeting_ch)
        ZIPPER(out_ch, params.zip)
    }

    // Task 8 - Create a process that zips the file created in the UPPERCASE process in "zip", "gzip" AND "bzip2" format. Print out the paths to the zipped files in the console

    if (params.step == 8) {
        greeting_ch = Channel.of("Hello world!")
        txt_ch = UPPERCASE(greeting_ch)
        out_ch = ZIPPER_ALL(txt_ch)
        out_ch.view{files ->
            "Created files:\n" + files.join('\n')}
    }

    // Task 9 - Create a process that reads in a list of names and titles from a channel and writes them to a file.
    //          Store the file in the "results" directory under the name "names.tsv"

    if (params.step == 9) {
        in_ch = channel.of(
            ['name': 'Harry', 'title': 'student'],
            ['name': 'Ron', 'title': 'student'],
            ['name': 'Hermione', 'title': 'student'],
            ['name': 'Albus', 'title': 'headmaster'],
            ['name': 'Snape', 'title': 'teacher'],
            ['name': 'Hagrid', 'title': 'groundkeeper'],
            ['name': 'Dobby', 'title': 'hero'],
        )

        out_ch = WRITETOFILE(in_ch.toList())
        out_ch.view()
    }

}