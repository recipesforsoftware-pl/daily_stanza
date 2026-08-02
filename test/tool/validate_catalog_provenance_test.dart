import 'package:flutter_test/flutter_test.dart';

import '../../tool/catalog_provenance_validator.dart';

const _defaultCandidateIds = <String>{
  'william_blake_the_tyger',
  'william_blake_the_lamb',
  'william_blake_london',
  'juliusz_slowacki_testament_moj',
  'jan_kochanowski_na_zdrowie',
};

const _defaultCandidateLanguages = <String, String>{
  'william_blake_the_tyger': 'en',
  'william_blake_the_lamb': 'en',
  'william_blake_london': 'en',
  'juliusz_slowacki_testament_moj': 'pl',
  'jan_kochanowski_na_zdrowie': 'pl',
};

Map<String, dynamic> _validProvenance({
  int schemaVersion = 1,
  String purpose = 'Provenance manifest',
  List<Map<String, dynamic>> records = const [],
}) => {'schemaVersion': schemaVersion, 'purpose': purpose, 'records': records};

Map<String, dynamic> _allTrueChecks() => {
  'sourceReachable': true,
  'titleMatched': true,
  'authorMatched': true,
  'languageMatched': true,
  'noTranslationDetected': true,
  'editionIdentified': true,
  'deathYearRecorded': true,
  'exactTextSourceAvailable': true,
  'rightsNoticeLocated': true,
};

Map<String, dynamic> _manualReviewChecks() => {
  'sourceReachable': false,
  'titleMatched': false,
  'authorMatched': true,
  'languageMatched': true,
  'noTranslationDetected': true,
  'editionIdentified': false,
  'deathYearRecorded': true,
  'exactTextSourceAvailable': false,
  'rightsNoticeLocated': false,
};

Map<String, dynamic> _validRecord({
  String candidateId = 'william_blake_the_tyger',
  int authorDeathYear = 1827,
  String authorDeathYearSourceUrl =
      'https://en.wikipedia.org/wiki/William_Blake',
  String sourceUrl = 'https://en.wikisource.org/wiki/The_Tyger',
  String sourceRightsEvidenceUrl = 'https://en.wikisource.org/wiki/The_Tyger',
  String sourceRetrievalDate = '2026-07-30',
  String rightsStatusCandidate = 'public_domain_candidate',
  String reviewStatus = 'pending_human_review',
  Map<String, dynamic>? automatedChecks,
  String reviewNotes = 'Candidate record pending human review.',
}) => {
  'candidateId': candidateId,
  'authorDeathYear': authorDeathYear,
  'authorDeathYearSourceUrl': authorDeathYearSourceUrl,
  'sourceUrl': sourceUrl,
  'sourceRightsEvidenceUrl': sourceRightsEvidenceUrl,
  'sourceRetrievalDate': sourceRetrievalDate,
  'rightsStatusCandidate': rightsStatusCandidate,
  'reviewStatus': reviewStatus,
  'automatedChecks': Map<String, dynamic>.from(
    automatedChecks ?? _allTrueChecks(),
  ),
  'reviewNotes': reviewNotes,
};

void main() {
  group('CatalogProvenanceValidator – structural validation', () {
    test('1. valid single public-domain candidate record passes', () {
      final provenance = _validProvenance(records: [_validRecord()]);
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
        candidateLanguages: _defaultCandidateLanguages,
      );
      expect(result.isValid, isTrue);
    });

    test('2. missing records array fails', () {
      final provenance = _validProvenance()..remove('records');
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'records'), isTrue);
    });

    test('3. wrong schemaVersion fails', () {
      final provenance = _validProvenance(
        schemaVersion: 2,
        records: [_validRecord()],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'schemaVersion'), isTrue);
    });

    test('4. empty purpose fails', () {
      final provenance = _validProvenance(
        purpose: '',
        records: [_validRecord()],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'purpose'), isTrue);
    });
  });

  group('CatalogProvenanceValidator – record field validation', () {
    test('5. empty candidateId fails', () {
      final provenance = _validProvenance(
        records: [_validRecord(candidateId: '')],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'candidateId'), isTrue);
    });

    test('6. duplicate candidateId fails', () {
      final provenance = _validProvenance(
        records: [
          _validRecord(candidateId: 'dup_id'),
          _validRecord(candidateId: 'dup_id'),
        ],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: {'dup_id'},
      );
      expect(result.isValid, isFalse);
      expect(
        result.errors.any(
          (e) => e.field == 'candidateId' && e.message.contains('duplicate'),
        ),
        isTrue,
      );
    });

    test('7. candidateId not in catalog_candidates fails', () {
      final provenance = _validProvenance(
        records: [_validRecord(candidateId: 'nonexistent_poem')],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isFalse);
      expect(
        result.errors.any(
          (e) => e.field == 'candidateId' && e.message.contains('not found'),
        ),
        isTrue,
      );
    });

    test('8. implausible death year fails', () {
      final provenance = _validProvenance(
        records: [_validRecord(authorDeathYear: 1200)],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'authorDeathYear'), isTrue);
    });

    test('9. future death year fails', () {
      final provenance = _validProvenance(
        records: [_validRecord(authorDeathYear: 2050)],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'authorDeathYear'), isTrue);
    });

    test('10. recent death year (Life+70 not expired) fails', () {
      final provenance = _validProvenance(
        records: [_validRecord(authorDeathYear: 1980)],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isFalse);
      expect(
        result.errors.any(
          (e) =>
              e.field == 'authorDeathYear' &&
              e.message.contains('not yet expired'),
        ),
        isTrue,
      );
    });

    test('11. missing death year source URL fails', () {
      final provenance = _validProvenance(
        records: [_validRecord(authorDeathYearSourceUrl: '')],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isFalse);
      expect(
        result.errors.any((e) => e.field == 'authorDeathYearSourceUrl'),
        isTrue,
      );
    });

    test('12. invalid death year source URL fails', () {
      final provenance = _validProvenance(
        records: [_validRecord(authorDeathYearSourceUrl: 'http://example.com')],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isFalse);
      expect(
        result.errors.any((e) => e.field == 'authorDeathYearSourceUrl'),
        isTrue,
      );
    });

    test('13. empty source URL fails', () {
      final provenance = _validProvenance(
        records: [_validRecord(sourceUrl: '')],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'sourceUrl'), isTrue);
    });

    test('14. invalid source URL fails', () {
      final provenance = _validProvenance(
        records: [_validRecord(sourceUrl: 'http://example.com')],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isFalse);
      expect(
        result.errors.any(
          (e) => e.field == 'sourceUrl' && e.message.contains('HTTPS'),
        ),
        isTrue,
      );
    });

    test('15. invalid retrieval date format fails', () {
      final provenance = _validProvenance(
        records: [_validRecord(sourceRetrievalDate: '30-07-2026')],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isFalse);
      expect(
        result.errors.any((e) => e.field == 'sourceRetrievalDate'),
        isTrue,
      );
    });

    test('16. forbidden rightsStatus public_domain fails', () {
      final provenance = _validProvenance(
        records: [_validRecord(rightsStatusCandidate: 'public_domain')],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isFalse);
      expect(
        result.errors.any((e) => e.field == 'rightsStatusCandidate'),
        isTrue,
      );
    });

    test('17. invalid rightsStatus fails', () {
      final provenance = _validProvenance(
        records: [_validRecord(rightsStatusCandidate: 'copyright')],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isFalse);
      expect(
        result.errors.any((e) => e.field == 'rightsStatusCandidate'),
        isTrue,
      );
    });

    test('18. forbidden reviewStatus source_verified fails', () {
      final provenance = _validProvenance(
        records: [_validRecord(reviewStatus: 'source_verified')],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'reviewStatus'), isTrue);
    });

    test('19. invalid reviewStatus fails', () {
      final provenance = _validProvenance(
        records: [_validRecord(reviewStatus: 'approved')],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'reviewStatus'), isTrue);
    });

    test('20. missing reviewNotes fails', () {
      final provenance = _validProvenance(
        records: [_validRecord(reviewNotes: '')],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'reviewNotes'), isTrue);
    });

    test('21. unknown field in record fails', () {
      final provenance = _validProvenance(
        records: [_validRecord()..['extraField'] = 'unexpected'],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'extraField'), isTrue);
    });
  });

  group('CatalogProvenanceValidator – status value acceptance', () {
    test('22. pending_human_review is accepted', () {
      final provenance = _validProvenance(
        records: [_validRecord(reviewStatus: 'pending_human_review')],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isTrue);
    });

    test('23. replacement_candidate_required is accepted', () {
      final provenance = _validProvenance(
        records: [
          _validRecord(
            reviewStatus: 'replacement_candidate_required',
            rightsStatusCandidate: 'rejected',
            automatedChecks: _manualReviewChecks(),
          ),
        ],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isTrue);
    });

    test('24. rejected_source is accepted', () {
      final provenance = _validProvenance(
        records: [
          _validRecord(
            reviewStatus: 'rejected_source',
            rightsStatusCandidate: 'rejected',
            automatedChecks: _manualReviewChecks(),
          ),
        ],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isTrue);
    });

    test('25. required_manual_legal_review is accepted', () {
      final provenance = _validProvenance(
        records: [
          _validRecord(
            reviewStatus: 'pending_human_review',
            rightsStatusCandidate: 'required_manual_legal_review',
            automatedChecks: _manualReviewChecks(),
          ),
        ],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isTrue);
    });
  });

  group('CatalogProvenanceValidator – automatedChecks validation', () {
    test('26. missing automatedChecks map fails', () {
      final record = _validRecord()..remove('automatedChecks');
      final provenance = _validProvenance(records: [record]);
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.field == 'automatedChecks'), isTrue);
    });

    test('27. false automatedCheck is accepted for manual review', () {
      final provenance = _validProvenance(
        records: [
          _validRecord(
            rightsStatusCandidate: 'required_manual_legal_review',
            automatedChecks: _manualReviewChecks(),
          ),
        ],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isTrue);
    });

    test(
      '28. public_domain_candidate with required check false is rejected',
      () {
        final provenance = _validProvenance(
          records: [
            _validRecord(
              rightsStatusCandidate: 'public_domain_candidate',
              automatedChecks: {..._allTrueChecks(), 'sourceReachable': false},
            ),
          ],
        );
        final result = CatalogProvenanceValidator.validateData(
          provenance: provenance,
          candidateIds: _defaultCandidateIds,
        );
        expect(result.isValid, isFalse);
        expect(
          result.errors.any(
            (e) =>
                e.field == 'automatedChecks.sourceReachable' &&
                e.message.contains('public_domain_candidate'),
          ),
          isTrue,
        );
      },
    );

    test('29. unknown automatedCheck field fails', () {
      final provenance = _validProvenance(
        records: [
          _validRecord(
            automatedChecks: {..._allTrueChecks(), 'extraCheck': true},
          ),
        ],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isFalse);
      expect(
        result.errors.any((e) => e.field == 'automatedChecks.extraCheck'),
        isTrue,
      );
    });

    test('30. non-boolean automatedCheck fails', () {
      final provenance = _validProvenance(
        records: [
          _validRecord(
            automatedChecks: {..._allTrueChecks(), 'sourceReachable': 'yes'},
          ),
        ],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
      );
      expect(result.isValid, isFalse);
      expect(
        result.errors.any((e) => e.field == 'automatedChecks.sourceReachable'),
        isTrue,
      );
    });
  });

  group('CatalogProvenanceValidator – summary', () {
    test('31. summary returns correct counts', () {
      final provenance = _validProvenance(
        records: [
          _validRecord(
            candidateId: 'william_blake_the_tyger',
            authorDeathYear: 1827,
            rightsStatusCandidate: 'public_domain_candidate',
            automatedChecks: _allTrueChecks(),
          ),
          _validRecord(
            candidateId: 'william_blake_the_lamb',
            authorDeathYear: 1827,
            rightsStatusCandidate: 'public_domain_candidate',
            automatedChecks: _allTrueChecks(),
          ),
          _validRecord(
            candidateId: 'juliusz_slowacki_testament_moj',
            authorDeathYear: 1849,
            rightsStatusCandidate: 'required_manual_legal_review',
            automatedChecks: _manualReviewChecks(),
          ),
        ],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
        candidateLanguages: _defaultCandidateLanguages,
      );
      expect(result.summary.totalRecords, 3);
      expect(result.summary.publicDomainCandidates, 2);
      expect(result.summary.manualLegalReviewRecords, 1);
      expect(result.summary.replacementCandidates, 0);
      expect(result.summary.rejectedSources, 0);
      expect(result.summary.incompleteChecksRecords, 1);
      expect(result.summary.englishRecords, 2);
      expect(result.summary.polishRecords, 1);
      expect(result.summary.deathYearRange, '1827 – 1849');
    });

    test('32. replacement candidates counted correctly', () {
      final provenance = _validProvenance(
        records: [
          _validRecord(
            candidateId: 'william_blake_the_tyger',
            rightsStatusCandidate: 'public_domain_candidate',
            automatedChecks: _allTrueChecks(),
          ),
          _validRecord(
            candidateId: 'juliusz_slowacki_testament_moj',
            reviewStatus: 'replacement_candidate_required',
            rightsStatusCandidate: 'rejected',
            automatedChecks: _manualReviewChecks(),
          ),
        ],
      );
      final result = CatalogProvenanceValidator.validateData(
        provenance: provenance,
        candidateIds: _defaultCandidateIds,
        candidateLanguages: _defaultCandidateLanguages,
      );
      expect(result.summary.publicDomainCandidates, 1);
      expect(result.summary.replacementCandidates, 1);
      expect(result.summary.incompleteChecksRecords, 1);
    });
  });
}
