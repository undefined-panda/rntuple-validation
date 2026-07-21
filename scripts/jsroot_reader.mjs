import { writeFileSync, mkdirSync, existsSync } from 'fs';

export function writeJson(dict_input, output, marker=null) {
    let dict_string = JSON.stringify(dict_input, null, 2);
    dict_string += "\n"; // read.C makros have an empty new line at the end

    // create folder if not exist and output contains folder path
    let output_dir = output.split("/").slice(0, -1).join("/");
    if (output_dir !== "") {
        if (!existsSync(output_dir)){
            mkdirSync(output_dir, { recursive: true });
        }
    }

    if (marker !== null) {
        dict_string = dict_string.replace(new RegExp(`"${marker}(-?\\d+)${marker}"`, 'g'),'$1');
    }

    writeFileSync(output, dict_string);
}
