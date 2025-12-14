// @ts-check
import withNuxt from "./.nuxt/eslint.config.mjs";

export default withNuxt();
// Your custom configs here

module.exports = {
  rules: {
    quotes: ["error", "single"],
    // или отключите:
    // 'quotes': 'off'
  },
};
