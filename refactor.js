const fs = require('fs');
const path = require('path');

const libDir = 'e:/Mt FlutterProject/alaref/lib';
const mainFile = path.join(libDir, 'main.dart');

const fileContent = fs.readFileSync(mainFile, 'utf-8');
const lines = fileContent.split(/\r?\n/);

const fileSections = {
    'main.dart': { start: 1, end: 32 },
    'features/main/presentation/pages/main_wrapper.dart': { start: 33, end: 112 },
    'features/home/presentation/pages/home_screen.dart': { start: 113, end: 1545 },
    'features/stages/presentation/pages/stages_screen.dart': { start: 1546, end: 1865 },
    'features/profile/presentation/pages/profile_screen.dart': { start: 1866, end: 2216 },
    'core/enums/stage.dart': { start: 2364, end: 2366 },
    'features/courses/presentation/pages/my_courses_screen.dart': {
        parts: [{ start: 2217, end: 2363 }, { start: 2367, end: 2503 }]
    },
    'features/stages/presentation/pages/stage_subjects_screen.dart': { start: 2504, end: 3016 },
    'core/widgets/shared_widgets.dart': { start: 3017, end: lines.length }
};

function getLines(start, end) {
    return lines.slice(start - 1, end).join('\n');
}

const imports = {
    'features/main/presentation/pages/main_wrapper.dart':
        `import 'package:flutter/material.dart';\n` +
        `import '../../home/presentation/pages/home_screen.dart';\n` +
        `import '../../courses/presentation/pages/my_courses_screen.dart';\n` +
        `import '../../stages/presentation/pages/stages_screen.dart';\n` +
        `import '../../profile/presentation/pages/profile_screen.dart';\n`,
    'features/home/presentation/pages/home_screen.dart':
        `import 'package:flutter/material.dart';\n`,
    'features/stages/presentation/pages/stages_screen.dart':
        `import 'package:flutter/material.dart';\n` +
        `import '../../../core/enums/stage.dart';\n` +
        `import 'stage_subjects_screen.dart';\n`,
    'features/profile/presentation/pages/profile_screen.dart':
        `import 'package:flutter/material.dart';\n`,
    'features/courses/presentation/pages/my_courses_screen.dart':
        `import 'package:flutter/material.dart';\n` +
        `import 'dart:async';\n` +
        `import '../../../core/enums/stage.dart';\n`,
    'features/stages/presentation/pages/stage_subjects_screen.dart':
        `import 'package:flutter/material.dart';\n` +
        `import '../../../core/enums/stage.dart';\n` +
        `import '../../../core/widgets/shared_widgets.dart';\n`,
    'core/widgets/shared_widgets.dart':
        `import 'package:flutter/material.dart';\n`
};

for (const [relPath, info] of Object.entries(fileSections)) {
    if (relPath === 'main.dart') continue;

    let content = '';
    if (info.parts) {
        content = info.parts.map(p => getLines(p.start, p.end)).join('\n');
    } else {
        content = getLines(info.start, info.end);
    }

    // Prepend imports
    if (imports[relPath]) {
        content = imports[relPath] + '\n' + content;
    }

    const fullPath = path.join(libDir, relPath);
    fs.mkdirSync(path.dirname(fullPath), { recursive: true });
    fs.writeFileSync(fullPath, content, 'utf-8');
    console.log(`Created: ${relPath}`);
}

const newMainContent =
    `import 'package:flutter/material.dart';\n` +
    `import 'features/main/presentation/pages/main_wrapper.dart';\n\n` +
    getLines(4, 32);

fs.writeFileSync(mainFile, newMainContent, 'utf-8');
console.log('Updated: main.dart');
