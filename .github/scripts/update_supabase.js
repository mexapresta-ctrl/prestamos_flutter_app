const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = (process.env.SUPABASE_URL || '').trim();
const supabaseKey = (process.env.SUPABASE_SERVICE_ROLE_KEY || '').trim();
const runNumber = (process.env.RUN_NUMBER || '').trim();
const repository = (process.env.REPO || '').trim();

if (!supabaseUrl || !supabaseKey) {
  console.error('ERROR: SUPABASE_URL o SUPABASE_SERVICE_ROLE_KEY no están configurados.');
  console.error('  SUPABASE_URL length:', supabaseUrl.length);
  console.error('  KEY length:', supabaseKey.length);
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function updateConfig() {
  const version = '1.0.' + runNumber;
  const apkUrl = 'https://github.com/' + repository + '/releases/latest/download/app-release.apk';

  console.log('Actualizando Supabase:');
  console.log('  min_version =', version);
  console.log('  apk_url     =', apkUrl);

  const { error: err1 } = await supabase
    .from('app_config')
    .update({ value: version })
    .eq('key', 'min_version');

  if (err1) {
    console.error('Error actualizando min_version:', err1.message);
    process.exit(1);
  }

  const { error: err2 } = await supabase
    .from('app_config')
    .update({ value: apkUrl })
    .eq('key', 'apk_url');

  if (err2) {
    console.error('Error actualizando apk_url:', err2.message);
    process.exit(1);
  }

  console.log('Supabase actualizado correctamente.');
}

updateConfig().catch((e) => {
  console.error('Error inesperado:', e.message);
  process.exit(1);
});
