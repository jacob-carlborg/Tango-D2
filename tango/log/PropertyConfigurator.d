/*******************************************************************************

        copyright:      Copyright (c) 2004 Kris Bell. All rights reserved

        license:        BSD style: $(LICENSE)
      
        version:        Split from Configurator.d, November 2005
        
        author:         Kris

*******************************************************************************/

module tango.log.PropertyConfigurator;

version (Isolated) {}
else
{
private import  tango.text.properties;

private import  tango.log.Logger,
                tango.log.Layout,
                tango.log.DateLayout,
                tango.log.Configurator,
                tango.log.ConsoleAppender;

/*******************************************************************************

        A utility class for initializing the basic behaviour of the
        default logging hierarchy.

        PropertyConfigurator parses a much simplified version of the 
        property file. tango.log only supports the settings of Logger 
        levels at this time; setup of Appenders and Layouts are currently 
        done "in the code", though this should not be a major hardship. 

*******************************************************************************/

public class PropertyConfigurator
{
        private static Logger.Level[char[]] map;

        /***********************************************************************
        
                Populate a map of acceptable level names

        ***********************************************************************/

        static this()
        {
                map["TRACE"]    = Logger.Level.Trace;
                map["trace"]    = Logger.Level.Trace;
                map["INFO"]     = Logger.Level.Info;
                map["info"]     = Logger.Level.Info;
                map["WARN"]     = Logger.Level.Warn;
                map["warn"]     = Logger.Level.Warn;
                map["ERROR"]    = Logger.Level.Error;
                map["error"]    = Logger.Level.Error;
                map["FATAL"]    = Logger.Level.Fatal;
                map["fatal"]    = Logger.Level.Fatal;
                map["NONE"]     = Logger.Level.None;
                map["none"]     = Logger.Level.None;
        }

        /***********************************************************************
        
                Add a default StdioAppender, with a SimpleTimerLayout, to 
                the root node. The activity levels of all nodes are set
                via a property file with name=value pairs specified that
                follow this format:

                name: the actual logger name, in dot notation format. The
                name "root" is reserved to match the root logger node.

                value: one of TRACE, INFO, WARN, ERROR, FATAL or NONE (or
                the lowercase equivalents).

                For example, the declaration

                tango.unittest=INFO

                sets the level of the logger called "tango.unittest".

        ***********************************************************************/

        static void configure (char[] filepath)
        {
                void loader (char[] name, char[] value)
                {
                        Logger l;

                        if (name == "root")
                            l = Logger.getRootLogger ();                            
                        else
                           l = Logger.getLogger (name);

                        if (l && value in map)
                            l.setLevel (map[value]);
                }

                // setup the basic stuff
                BasicConfigurator.defaultAppender ();

                // read and parse properties from file
                Properties.load (filepath, &loader);
        }
}
}
