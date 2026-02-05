// .prettierrc.mjs
/** @type {import("prettier").Config} */
export default {
  plugins: ["prettier-plugin-astro"], // enable the Astro plugin
  overrides: [
    {
      files: "*.astro", // for Astro files
      options: {
        parser: "astro", // use the Astro parser
      },
    },
  ],
};
