const fs = require('fs');
const path = require('path');

function getAllFiles(dirPath) {
    const files = fs.readdirSync(dirPath);

    let arrayOfFiles = [];

    files.forEach(function (file) {
        if (fs.statSync(dirPath + '/' + file).isDirectory()) {
            arrayOfFiles = arrayOfFiles.concat(
                getAllFiles(dirPath + '/' + file)
            );
        } else {
            arrayOfFiles.push(path.join(process.cwd(), dirPath, '/', file));
        }
    });
    return arrayOfFiles;
}

for (const file of getAllFiles('src')) {
    if (path.extname(file) == '.lua') {
        const parsedPath = path.parse(file);
        fs.renameSync(file, parsedPath.dir + '/' + parsedPath.name + '.luau');
    }
}