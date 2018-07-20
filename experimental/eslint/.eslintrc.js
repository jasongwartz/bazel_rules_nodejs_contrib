module.exports = {
    root: true,
    extends: ['airbnb-base'],
    env: {
        node: true,
        browser: true,
        es6: true,
    },
    parserOptions: {
        ecmaVersion: 2018,
        parser: 'babel-eslint',
    },
    rules: {
        // comma-dangle would cost us another babel-transform so we skip it for now
        'comma-dangle': ['error', 'always-multiline'],
        'function-paren-newline': ['off'],
        'import/no-extraneous-dependencies': ['error', { devDependencies: true }],
        'indent': ['error', 2],
        'no-alert': 'error',
        'no-console': 'warn',
        'no-new': 'off',
        'no-restricted-globals': ['error', 'event'],
        'object-curly-newline': 'off',
        'quote-props': ['error', 'consistent-as-needed'],
        'space-before-function-paren': 'warn',
    },
};
