// This is maybe a bit of a hack but we are using rollup as a vue "compiler" rather than as a
// bundler, by telling it to ignore all externals (i.e. imports). This is much easier than writing
// a custom vue compiler ourselves.
import path from 'path';
import VuePlugin from 'rollup-plugin-vue';

const input = 'TMPL_src_name';
export default {
    plugins: [
        VuePlugin()
    ],
    output: {
        format: 'es',
        strict: false,
        interop: false
    },
    external: (id) => {
        const ext = (id !== input) && (!id.includes(`${path.basename(input)}?rollup-plugin-vue=script.js`));
        return ext;
    }
};
