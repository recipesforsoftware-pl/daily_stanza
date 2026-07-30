import { readFileSync } from 'fs';

const ALLOWED_PROJECT = 'daily-stanza-prod-ks';

async function main() {
  const args = process.argv.slice(2);
  const dryRun = !args.includes('--execute');
  const hasProjectFlag = args.includes('--confirm-project=' + ALLOWED_PROJECT);
  const hasRightsFlag = args.includes('--confirm-rights-reviewed');

  if (dryRun) {
    console.log('[DRY-RUN] Mode active. Use --execute to write to Firestore.');
  }

  if (!dryRun && !hasProjectFlag) {
    console.error(
      'Error: --confirm-project=' + ALLOWED_PROJECT +
      ' is required to proceed.',
    );
    process.exit(1);
  }

  if (!dryRun && !hasRightsFlag) {
    console.error(
      'Error: --confirm-rights-reviewed is required to proceed.',
    );
    process.exit(1);
  }

  if (!dryRun) {
    const hasProjectArg = args.some(a => a.startsWith('--confirm-project='));
    const expectedPrefix = '--confirm-project=' + ALLOWED_PROJECT;
    if (!hasProjectArg || !args.includes(expectedPrefix)) {
      console.error(
        'Error: --confirm-project=' + ALLOWED_PROJECT +
        ' is required to proceed.',
      );
      process.exit(1);
    }
  }

  const poemsPath = 'seed/poems.json';
  const dailyPath = 'seed/daily_poems.json';

  const poems = JSON.parse(readFileSync(poemsPath, 'utf-8'));
  const dailyPoems = JSON.parse(readFileSync(dailyPath, 'utf-8'));

  if (dryRun) {
    console.log('\n=== DRY-RUN VALIDATION ===');
    console.log('Project: ' + ALLOWED_PROJECT);
    console.log('Poems: ' + poems.length);
    console.log('Daily assignments: ' + dailyPoems.length);
    console.log('All document IDs explicit, no deletes planned.');
    console.log('=== DRY-RUN PASSED ===\n');
    console.log(
      'Re-run with --execute to write to project "' +
      ALLOWED_PROJECT + '".',
    );
    return;
  }

  const { applicationDefault, getApps, initializeApp } = await import(
    'firebase-admin/app'
  );
  const { getFirestore } = await import('firebase-admin/firestore');

  if (getApps().length === 0) {
    initializeApp({
      credential: applicationDefault(),
      projectId: ALLOWED_PROJECT,
    });
  }

  const db = getFirestore();

  const BATCH_LIMIT = 400;
  let written = 0;

  async function writeCollection(collection, docs) {
    for (let i = 0; i < docs.length; i += BATCH_LIMIT) {
      const batch = db.batch();
      const chunk = docs.slice(i, i + BATCH_LIMIT);
      for (const doc of chunk) {
        const id = doc.id;
        const ref = db.collection(collection).doc(id);
        const data = { ...doc };
        delete data.id;
        batch.set(ref, data);
      }
      await batch.commit();
      written += chunk.length;
      console.log('  ' + collection + ': wrote ' + written + '/' + docs.length);
    }
  }

  console.log('\nWriting to project "' + ALLOWED_PROJECT + '"...\n');

  await writeCollection('poems', poems);
  await writeCollection('daily_poems', dailyPoems);

  const totalExpected = poems.length + dailyPoems.length;
  if (written !== totalExpected) {
    console.error(
      '\nError: expected ' + totalExpected + ' documents, wrote ' + written + '.',
    );
    process.exit(1);
  }

  console.log('\nDone. ' + written + ' documents written.');
  console.log('Poems: ' + poems.length + ', Daily poems: ' + dailyPoems.length);
}

main().catch((err) => {
  console.error('Import failed:', err.message);
  process.exit(1);
});
