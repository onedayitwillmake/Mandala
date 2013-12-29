module.exports = function( grunt ) {
	grunt.initConfig({
        less: {
            buildCSS: {
                files: {
                "../css/semantic.css": "../less/semantic-ui/**/*.less",
                "../css/mandala.css": "../less/mandala/mandala.less"
                }
            }
        },
        watch: {
            files: "../less/**/*.less",
            tasks: ["less:buildCSS"]
        }
	});

	// Modules used
    grunt.loadNpmTasks('grunt-contrib-less');
    grunt.loadNpmTasks('grunt-contrib-watch');

	grunt.registerTask('default', ['less']);
};