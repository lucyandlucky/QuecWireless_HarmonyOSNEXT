import { cpSync, existsSync, mkdirSync, mkdtempSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const projectArgument = process.argv[2];
if (!projectArgument) {
  console.error('Usage: node build-rn-bundle.mjs <React Native project directory>');
  process.exit(1);
}

const projectDirectory = resolve(projectArgument);
const outputDirectory = fileURLToPath(
  new URL('../src/main/resources/rawfile/rn/device-panel/', import.meta.url),
);
const stagingDirectory = mkdtempSync(join(tmpdir(), 'quec-device-panel-bundle-'));
try {
  const result = spawnSync(
    process.execPath,
    [
      resolve(projectDirectory, 'node_modules/react-native/cli.js'),
      'bundle-harmony',
      '--dev', 'false',
      '--bundle-output', resolve(stagingDirectory, 'bundle.harmony.js'),
      '--assets-dest', resolve(stagingDirectory, 'assets'),
    ],
    { cwd: projectDirectory, stdio: 'inherit' },
  );

  if (result.status !== 0 || !existsSync(resolve(stagingDirectory, 'bundle.harmony.js'))) {
    console.error(result.error?.message ?? 'The RN bundle was not generated.');
    process.exitCode = result.status || 1;
  } else {
    mkdirSync(outputDirectory, { recursive: true });
    cpSync(stagingDirectory, outputDirectory, { recursive: true });
    console.log(`Device panel bundle: ${resolve(outputDirectory, 'bundle.harmony.js')}`);
  }
} finally {
  rmSync(stagingDirectory, { recursive: true, force: true });
}
