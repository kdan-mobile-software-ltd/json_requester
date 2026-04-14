## [2.0.8] - 2026-04-08
- Update `addressable` to `2.9.0` to fix Regular Expression Denial of Service in Addressable templates.

## [2.0.7] - 2026-03-30
- Update RuboCop configuration to enforce double quotes for strings.
- Add RuboCop lint stage to CI pipeline.

## [2.0.6] - 2026-03-30
- Update mcp to version `0.9.2` for [Github GHSA-qvqr-5cv7-wh35](https://github.com/advisories/GHSA-qvqr-5cv7-wh35) security vulnerability warning.

## [2.0.5] - 2026-03-19
- Update json to version `2.19.2` for `CVE-2026-33210` format string injection vulnerability mitigation.
- Move development dependencies from `gemspec` to `Gemfile`.
- Add RuboCop configuration for project linting and exclude `spec/**/*` from `Metrics/BlockLength`.
- Remove the empty RSpec configuration block in `spec_helper`.
- Refresh the README structure and usage examples.
- Add `SECURITY.md` for vulnerability reporting guidelines.

## [2.0.4] - 2026-02-10
- Update Faraday to version `2.14.1` for SSRF vulnerability warning.

## [2.0.3] - 2025-12-31
- Update Faraday to version `2.14.0`.
- Update faraday-multipart to version `1.2.0`.
- Update uri to version `1.1.1` for [CVE-2025-61594](https://www.ruby-lang.org/en/news/2025/10/07/uri-cve-2025-61594/) URI Credential Leakage Bypass vulnerability warning.
- Update CI to use Ruby 3.4.8.

## [2.0.2] - 2025-09-23
- Update REXML to version `3.4.4` for [CVE-2025-58767](https://www.ruby-lang.org/en/news/2025/09/18/dos-rexml-cve-2025-58767/) DoS vulnerability warning.

## [2.0.1] - 2025-07-16
- Update Faraday to version `2.13.2` for better stability and performance.
- Update faraday-multipart to version `1.1.1`.
- Update CI to use Ruby 3.4.5.

## [2.0.0] - 2025-04-25

### Breaking changes

- Upgrade Faraday to version 2.x.
- Remove support for Ruby 2.7 and below.

### Features
- Add rspec for testing.

## [1.1.3] - 2024-10-28
- Replace `.present?` method with `object_present?` for string in `json_send` method. 

## [1.1.2] - 2024-06-28
- Accept `content_type_charset` keyword argument for `http_send` method.

## [1.1.1] - 2024-06-28
- Accept `content_type_charset` keyword argument for `json_send` method.

## [1.1.0] - 2023-12-07
- Drop support for Ruby 2.7 below.
- Add user_agent condition to use.
- Lock faraday to `1.10.3` version.

## [1.0.12] - 2023-10-26
- Add need_response_header condition to use.

## [1.0.11] - 2023-08-17
- Add sort params condition to use.
- Update README description.

## [1.0.10] - 2023-07-03
- Add timeout option.

## [1.0.9] - 2023-05-18
- Add gitlab templates.
- Update gemspec.
