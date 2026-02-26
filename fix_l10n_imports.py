#!/usr/bin/env python3
import os

files_to_fix = [
    'lib/presentation/common_widgets/vl_bottom_nav_bar.dart',
    'lib/presentation/common_widgets/vl_project_card.dart',
    'lib/presentation/screens/auth/login_screen.dart',
    'lib/presentation/screens/auth/register_screen.dart',
    'lib/presentation/screens/main/main_screen.dart',
    'lib/presentation/screens/messaging/messaging_screen.dart',
    'lib/presentation/screens/notifications/notifications_screen.dart',
    'lib/presentation/screens/profile/profile_screen.dart',
    'lib/presentation/screens/project/project_create_screen_enhanced.dart',
    'lib/presentation/screens/search/search_screen.dart',
    'lib/presentation/screens/settings/language_settings_screen.dart',
]

for file_path in files_to_fix:
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        content = content.replace(
            'package:flutter_gen/gen_l10n/app_localizations.dart',
            'package:venturelink/l10n/app_localizations.dart'
        )
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f'Fixed: {file_path}')
    except Exception as e:
        print(f'Error fixing {file_path}: {e}')

print('Done!')
