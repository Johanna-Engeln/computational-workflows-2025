params.path = false

process SPLITLETTERS {
    debug true

    input:
    tuple val(meta), val (file) 

    output:
    path "results/${file[1]}_*.txt"

    script:
    """
    mkdir -p results
    str="${file[0]}"
    prefix="${file[1]}"
    block_size=${meta.block_size}

    len=\${#str}
    i=0
    while [ \$i -lt \$len ]; do
        part=\${str:\$i:\$block_size}
        num=\$(( \$i / \$block_size + 1 ))
        echo "\$part" > results/\${prefix}_\${num}.txt
        i=\$(( \$i + \$block_size ))
    done
    """

} 

process CONVERTTOUPPER {
    debug true

    input:
    path file

    output:
    stdout

    script:
    """
    for f in $file; do
        tr '[:lower:]' '[:upper:]' < "\$f"
    done
    """
} 

workflow { 
    // 1. Read in the samplesheet (samplesheet_2.csv)  into a channel. The block_size will be the meta-map
    in_ch = channel.fromPath('samplesheet_2.csv')
        .splitCsv(header: true)
        .map { row -> 
            def meta = [block_size: row.block_size]
            def file = [row.input_str, row.out_name]
            [meta, file]}
    //in_ch.view()

    // 2. Create a process that splits the "in_str" into sizes with size block_size. The output will be a file for each block, named with the prefix as seen in the samplesheet_2
    split_ch = SPLITLETTERS(in_ch)
    //split_ch.view()

    // 4. Feed these files into a process that converts the strings to uppercase. The resulting strings should be written to stdout
    if (params.path == false) {
        CONVERTTOUPPER(split_ch)
    }

    // Print list of path
    if (params.path == true) {
        split_ch.view{files ->
            "Created files:\n" + files.join('\n')}
    }

    // read in samplesheet}

    // split the input string into chunks

    // lets remove the metamap to make it easier for us, as we won't need it anymore

    // convert the chunks to uppercase and save the files to the results directory

}