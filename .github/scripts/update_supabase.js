const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = (process.env.SUPABASE_URL || '').trim();
const supabaseKey = (process.env.SUPABASE_SERVICE_ROLE_KEY || '').trim();
const version = (process.env.APP_VERSION || '').trim();
const repository = (process.env.REPO || '').trim();

if (!supabaseUrl || !supabaseKey) {
  console.error('ERROR: SUPABASE_URL o SUPABASE_SERVICE_ROLE_KEY no están configurados.');
  console.error('  SUPABASE_URL length:', supabaseUrl.length);
  console.error('  KEY length:', supabaseKey.length);
  process.exit(1);
}

if (!version) {
  console.error('ERROR: APP_VERSION no está configurado.');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function updateConfig() {
  const apkUrl = 'https://github.com/' + repository + '/releases/latest/download/app-arm64-v8a-release.apk';

  console.log('Actualizando Supabase:');
  console.log('  min_version =', version);
  console.log('  apk_url     =', apkUrl);

  // Upsert min_version (insert if not exists, update if exists)
  const { error: err1 } = await supabase
    .from('app_config')
    .upsert({ key: 'min_version', value: version }, { onConflict: 'key' });

  if (err1) {
    console.error('Error actualizando min_version:', err1.message);
    process.exit(1);
  }

  // Upsert apk_url
  const { error: err2 } = await supabase
    .from('app_config')
    .upsert({ key: 'apk_url', value: apkUrl }, { onConflict: 'key' });

  if (err2) {
    console.error('Error actualizando apk_url:', err2.message);
    process.exit(1);
  }

  console.log('✅ Supabase actualizado correctamente.');
  console.log('   Usuarios con versión < ' + version + ' verán la pantalla de actualización.');
}

updateConfig().catch((e) => {
  console.error('Error inesperado:', e.message);
  process.exit(1);
});
