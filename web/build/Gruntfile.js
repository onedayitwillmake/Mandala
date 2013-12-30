var util = require("util");

var railsDir = "../../../";

var $layout = null;
var $welcome = null;
var $mandalaDart = null;
module.exports = function( grunt ){
  grunt.initConfig({
    less : {
      buildCSS: {
        files: {
          "../css/semantic.css": "../less/semantic-ui/**/*.less",
          "../css/mandala.css" : "../less/mandala/mandala.less"
        }
      }
    },
    dom_munger: {
      load_mandalaDart: {
        options:{callback: function($){ $mandalaDart = $; }},
        src: '../mandala.html'
      }
    },
    copy: {
      main: {
        files: [
          // Fonts
          {expand: true, cwd: '../', src: ['fonts/*'], dest: railsDir + "app/assets/", filter: 'isFile'},
          // CSS
          {expand: true, cwd: '../', src: ['css/*'], dest: railsDir + "app/assets/", filter: 'isFile'},
          // Images excluding demo and editor assets
          {expand: true, cwd: '../', src: ['images/**'], dest: railsDir + "app/assets/", filter: 'isFile'},
          // JS
          {expand: true, cwd: '../', src: ['js/**'], dest: railsDir + "app/assets/", filter: 'isFile'},
          // DART
          {expand: true, cwd: '../', src: ['dart/**'], dest: railsDir + "app/assets/", filter: 'isFile'}
        ]
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
  grunt.loadNpmTasks('grunt-dom-munger');
  grunt.loadNpmTasks('grunt-contrib-copy');

  grunt.task.registerTask('foo', 'A sample task that logs stuff.', function(arg1, arg2) {
    $mandalaDart('script').each(function(i,e){
      console.log(i)
    });
//    console.log($mandalaDart('script').toString());
    grunt.file.write('../../../app/views/layouts/post_body.html.erb', $mandalaDart('script').toString())
  });

//  grunt.registerTask('default', ['dom_munger', 'foo']);
  grunt.registerTask('default', ['copy']);
};