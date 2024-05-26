fx_version "adamant"

description "MaveraV Store"
author "Wizard#2889"
version '1.0.0'
repository 'https://discord.gg/4aE4NswP9A'

game "gta5"

client_script { 
  '@maV_core/Locale.lua',
  'main/locales/*.lua',
  "main/client.lua"
}

server_script {
  '@maV_core/Locale.lua',
  'main/locales/*.lua',
  "main/server.lua",
} 

shared_script "main/shared.lua"


ui_page "index.html"

files {
    'index.html',
    'vue.js',
    'assets/**/*.*',
    'assets/font/*.otf',  
	  'assets/font/Mark_Simonson_Proxima_Nova_Extra_Condensed_Light_Italic_TheFontsMaster.com.otf',
    'assets/font/Mark_Simonson_Proxima_Nova_Condensed_Light_Italic_TheFontsMaster.com.otf',  
    'assets/font/Mark_Simonson_Proxima_Nova_Condensed_Thin_TheFontsMaster.com.otf',
}

dependencies {
  'maV_core'
}

escrow_ignore {
  'main/shared.lua',
  'main/locales/en.lua'
}

lua54 'yes'
