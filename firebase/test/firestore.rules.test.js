// Firestore Security Rules tests for daily_stanza.
//
// Run: firebase emulators:start --only firestore &
//      cd firebase && npm install && npm test

const { initializeTestEnvironment, assertFails, assertSucceeds } =
  require('@firebase/rules-unit-testing');

/** Project ID used by the Firebase emulator suite. */
const PROJECT_ID = 'demo-daily-stanza';

let testEnv;

beforeAll(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: require('fs').readFileSync(
        require('path').resolve(__dirname, '..', '..', 'firestore.rules'),
        'utf8',
      ),
    },
  });
});

afterAll(async () => {
  await testEnv?.cleanup();
});

// ---------------------------------------------------------------------------
// Poems collection
// ---------------------------------------------------------------------------

describe('poems collection', () => {
  /** Unauthenticated Firestore context. */
  const unauthed = () => testEnv.unauthenticatedContext().firestore();

  /** Returns an approved poem document. */
  function approvedPoem(id) {
    return {
      title: 'Test Poem',
      author: 'Author',
      languageCode: 'en',
      countryCode: 'US',
      content: 'Some verse.',
      sourceName: 'Source',
      sourceUrl: 'https://example.com',
      rightsStatus: 'public_domain',
      isApproved: true,
    };
  }

  test('allows read when isApproved is true', async () => {
    const db = unauthed();
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const adminDb = ctx.firestore();
      await adminDb.doc(`poems/test1`).set(approvedPoem('test1'));
    });

    const docRef = db.doc('poems/test1');
    await assertSucceeds(docRef.get());
  });

  test('denies read when isApproved is false', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const adminDb = ctx.firestore();
      await adminDb.doc('poems/test2').set({
        ...approvedPoem('test2'),
        isApproved: false,
      });
    });

    const db = unauthed();
    const docRef = db.doc('poems/test2');
    await assertFails(docRef.get());
  });

  test('denies unauthenticated write', async () => {
    const db = unauthed();
    const docRef = db.doc('poems/test3');
    await assertFails(
      docRef.set({
        ...approvedPoem('test3'),
      }),
    );
  });
});

// ---------------------------------------------------------------------------
// Daily poems collection
// ---------------------------------------------------------------------------

describe('daily_poems collection', () => {
  const unauthed = () => testEnv.unauthenticatedContext().firestore();

  function publishedAssignment() {
    return {
      date: '2026-07-28',
      languageCode: 'en',
      poemId: 'some_poem',
      isPublished: true,
    };
  }

  test('allows read when isPublished is true', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const adminDb = ctx.firestore();
      await adminDb.doc('daily_poems/en_20260728').set(publishedAssignment());
    });

    const db = unauthed();
    const docRef = db.doc('daily_poems/en_20260728');
    await assertSucceeds(docRef.get());
  });

  test('denies read when isPublished is false', async () => {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      const adminDb = ctx.firestore();
      await adminDb.doc('daily_poems/pl_20260728').set({
        ...publishedAssignment(),
        isPublished: false,
      });
    });

    const db = unauthed();
    const docRef = db.doc('daily_poems/pl_20260728');
    await assertFails(docRef.get());
  });

  test('denies unauthenticated write', async () => {
    const db = unauthed();
    const docRef = db.doc('daily_poems/en_20260729');
    await assertFails(docRef.set(publishedAssignment()));
  });
});
