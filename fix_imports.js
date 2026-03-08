const fs = require('fs');
const path = require('path');

const libDir = 'e:/Mt FlutterProject/alaref/lib';

// Let's just fix the files that were written with bad imports.
const readWrite = (relPath, replaceFunc) => {
    const p = path.join(libDir, relPath);
    let c = fs.readFileSync(p, 'utf-8');
    c = replaceFunc(c);
    fs.writeFileSync(p, c, 'utf-8');
}

// 1. main.dart
readWrite('main.dart', c => c.replace(
    'import \'features/main/presentation/pages/main_wrapper.dart\';',
    'import \'package:alaref/features/main/presentation/pages/main_wrapper.dart\';'
));

// 2. main_wrapper.dart
readWrite('features/main/presentation/pages/main_wrapper.dart', c => c.replace(
    `import '../../home/presentation/pages/home_screen.dart';\n` +
    `import '../../courses/presentation/pages/my_courses_screen.dart';\n` +
    `import '../../stages/presentation/pages/stages_screen.dart';\n` +
    `import '../../profile/presentation/pages/profile_screen.dart';`,
    `import 'package:alaref/features/home/presentation/pages/home_screen.dart';\n` +
    `import 'package:alaref/features/courses/presentation/pages/my_courses_screen.dart';\n` +
    `import 'package:alaref/features/stages/presentation/pages/stages_screen.dart';\n` +
    `import 'package:alaref/features/profile/presentation/pages/profile_screen.dart';`
));

// 3. stages_screen.dart
readWrite('features/stages/presentation/pages/stages_screen.dart', c => c.replace(
    `import '../../../core/enums/stage.dart';`,
    `import 'package:alaref/core/enums/stage.dart';`
));

// 4. my_courses_screen.dart
readWrite('features/courses/presentation/pages/my_courses_screen.dart', c => c.replace(
    `import '../../../core/enums/stage.dart';`,
    `import 'package:alaref/core/enums/stage.dart';`
));

// 5. stage_subjects_screen.dart
readWrite('features/stages/presentation/pages/stage_subjects_screen.dart', c => c.replace(
    `import '../../../core/enums/stage.dart';\nimport '../../../core/widgets/shared_widgets.dart';`,
    `import 'package:alaref/core/enums/stage.dart';\nimport 'package:alaref/core/widgets/shared_widgets.dart';`
));

console.log("Imports updated!");
