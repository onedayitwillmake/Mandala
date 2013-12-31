var util = require("util");

var railsDir = "../../../";

var $layout = null;
var $welcome = null;
var $mandalaDart = null;
module.exports = function( grunt ){
  grunt.initConfig({
    less      : {
      buildCSS: {
        files: {
          "../css/semantic.css": "../less/semantic-ui/**/*.less",
          "../css/mandala.css" : "../less/mandala/mandala.less"
        }
      }
    },
    dom_munger: {
      load_mandalaDart: {
        options: {callback: function( $ ){ $mandalaDart = $; }},
        src    : '../mandala.html'
      }
    },
    copy      : {
      main: {
        files: [
          // Fonts
          {expand: true, cwd: '../', src: ['fonts/*'], dest: railsDir+"public/", filter: 'isFile'},
          // CSS
          {expand: true, cwd: '../', src: ['css/*'], dest: railsDir+"public/", filter: 'isFile'},
          // Images excluding demo and editor assets
          {expand: true, cwd: '../', src: ['images/**'], dest: railsDir+"public/", filter: 'isFile'},
          // JS
          {expand: true, cwd: '../', src: ['js/**'], dest: railsDir+"public/", filter: 'isFile'},
          // DART
          {expand: true, cwd: '../', src: ['dart/**'], dest: railsDir+"public/", filter: 'isFile'},
          // DART - PACKAGES
          {expand: true, cwd: '../', src: ['dart/packages/**'], dest: railsDir+"public/", filter: 'isFile'}
        ]
      }
    },
    watch     : {
      files: "../less/**/*.less",
      tasks: ["less:buildCSS"]
    }
  });

  // Modules used
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-dom-munger');
  grunt.loadNpmTasks('grunt-contrib-copy');

  grunt.task.registerTask('foo', 'A sample task that logs stuff.', function( arg1, arg2 ){
    // Write all link tags
    grunt.file.write('../../../app/views/layouts/_head.html.erb',  $mandalaDart('link').toString().split("<").join("\n\t<") );
    // Write all script tags
    // any 'src=packages...' reference, change to src'=dart/packages...'
    var allScriptTags = $mandalaDart('script').toString().replace(/src\=\"packages/g, "src=\"dart/packages");
    grunt.file.write('../../../app/views/layouts/_post_body.html.erb', allScriptTags.split("<script").join("\n\t<script") );
  });

  grunt.registerTask('default', ['dom_munger', 'foo']);
};