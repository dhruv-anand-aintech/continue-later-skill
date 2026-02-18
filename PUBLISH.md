# Publishing Guide

## Step 1: Create GitHub Repository

1. Go to [github.com/new](https://github.com/new)
2. Create repo: `create-continuation-skill`
3. Description: "Generate comprehensive continuation.md handoff documentation for fresh sessions"
4. Add MIT license template
5. Clone and push:

```bash
cd /Users/dhruvanand/Code/create-continuation-skill
git remote add origin https://github.com/dhruvanand/create-continuation-skill.git
git branch -M main
git push -u origin main
```

## Step 2: Prepare for npm

1. Verify `package.json` is configured correctly (already done)
2. Build the package:

```bash
npm run build
```

3. Verify build output:

```bash
ls -la dist/
# Should show: index.js, index.d.ts, cli.js, types.js, generator.js, io.js
```

4. Test locally:

```bash
npm link
create-continuation --help
```

## Step 3: Publish to npm

1. Create npm account at [npmjs.com](https://npmjs.com)
2. Login locally:

```bash
npm login
# Enter username, password, and email
# If you have 2FA enabled: use One-Time Password
```

3. Publish:

```bash
npm publish
```

This will:
- Build the package
- Create a tarball
- Upload to npm registry
- Make it available via `npm install create-continuation-skill`

4. Verify:

```bash
npm view create-continuation-skill
npm info create-continuation-skill@latest
```

## Step 4: Test Installation

In a fresh directory:

```bash
mkdir test-install && cd test-install
npm init -y
npm install create-continuation-skill
# Test it:
./node_modules/.bin/create-continuation --help
```

## Step 5: Create GitHub Release

```bash
git tag v1.0.0
git push origin v1.0.0
```

Then on GitHub, go to Releases and create a release from the tag with notes.

## Future Updates

To publish a new version:

1. Update version in `package.json`
2. Update `CHANGELOG.md` with changes
3. Commit: `git commit -m "chore: bump version to 1.0.1"`
4. Tag: `git tag v1.0.1`
5. Push: `git push origin main --tags`
6. Publish: `npm publish`

## Version Numbers

Follow [Semantic Versioning](https://semver.org/):
- `MAJOR.MINOR.PATCH`
- `1.0.0` → `1.0.1` (patch fix)
- `1.0.0` → `1.1.0` (new feature, backward compatible)
- `1.0.0` → `2.0.0` (breaking change)

## Marketing

Share your package:
- Tweet with `#npm` and `#javascript`
- Post on dev.to, Medium, or your blog
- Add to awesome lists (e.g., awesome-nodejs)
- Ask for feedback in communities (Reddit r/javascript, DEV, etc.)

## Troubleshooting

**"You don't have permission to publish this package"**
- Either publish to a different name, or use a scoped package: `@yourusername/create-continuation-skill`
- To publish scoped: change `"name"` in package.json and run `npm publish --access public`

**"Package already exists"**
- Another user already took this name
- Consider: `@yourname/create-continuation-skill` or `continuation-skill-generator`

**Build output missing**
- Run `npm run build` first
- Verify `files` in package.json includes `"dist"`

## Next Steps

1. Get feedback from users
2. Add interactive CLI mode (promise in README)
3. Create VS Code extension that uses this package
4. Build GitHub Action for auto-generating continuations
