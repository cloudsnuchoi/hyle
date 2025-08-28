#!/usr/bin/env node

/**
 * Flutter MCP Server for Claude
 * Provides Flutter development tools and commands
 */

const { spawn } = require('child_process');
const readline = require('readline');

class FlutterMCPServer {
  constructor() {
    this.rl = readline.createInterface({
      input: process.stdin,
      output: process.stdout
    });
    
    this.projectPath = process.cwd();
  }

  async start() {
    // Send initial capabilities
    this.sendResponse({
      type: 'capabilities',
      capabilities: {
        tools: [
          {
            name: 'flutter_analyze',
            description: 'Run Flutter analyze to check for issues',
            inputSchema: {
              type: 'object',
              properties: {}
            }
          },
          {
            name: 'flutter_pub_get',
            description: 'Get Flutter dependencies',
            inputSchema: {
              type: 'object',
              properties: {}
            }
          },
          {
            name: 'flutter_run',
            description: 'Run Flutter app',
            inputSchema: {
              type: 'object',
              properties: {
                target: {
                  type: 'string',
                  description: 'Target file to run (e.g., lib/main_test_local.dart)'
                }
              }
            }
          },
          {
            name: 'flutter_test',
            description: 'Run Flutter tests',
            inputSchema: {
              type: 'object',
              properties: {}
            }
          },
          {
            name: 'flutter_clean',
            description: 'Clean Flutter build cache',
            inputSchema: {
              type: 'object',
              properties: {}
            }
          }
        ]
      }
    });

    // Listen for requests
    this.rl.on('line', async (line) => {
      try {
        const request = JSON.parse(line);
        await this.handleRequest(request);
      } catch (error) {
        this.sendError(`Failed to parse request: ${error.message}`);
      }
    });
  }

  async handleRequest(request) {
    if (request.method === 'tools/call') {
      const { name, arguments: args } = request.params;
      
      switch (name) {
        case 'flutter_analyze':
          await this.runFlutterCommand(['analyze']);
          break;
        case 'flutter_pub_get':
          await this.runFlutterCommand(['pub', 'get']);
          break;
        case 'flutter_run':
          const target = args.target || 'lib/main.dart';
          await this.runFlutterCommand(['run', '-d', 'chrome', '-t', target]);
          break;
        case 'flutter_test':
          await this.runFlutterCommand(['test']);
          break;
        case 'flutter_clean':
          await this.runFlutterCommand(['clean']);
          break;
        default:
          this.sendError(`Unknown tool: ${name}`);
      }
    }
  }

  async runFlutterCommand(args) {
    return new Promise((resolve, reject) => {
      const flutter = spawn('flutter', args, {
        cwd: this.projectPath,
        shell: true
      });

      let output = '';
      let errorOutput = '';

      flutter.stdout.on('data', (data) => {
        output += data.toString();
      });

      flutter.stderr.on('data', (data) => {
        errorOutput += data.toString();
      });

      flutter.on('close', (code) => {
        if (code === 0) {
          this.sendResponse({
            type: 'tool_result',
            content: output
          });
          resolve();
        } else {
          this.sendError(`Flutter command failed: ${errorOutput}`);
          reject(new Error(errorOutput));
        }
      });
    });
  }

  sendResponse(response) {
    console.log(JSON.stringify(response));
  }

  sendError(message) {
    this.sendResponse({
      type: 'error',
      error: message
    });
  }
}

// Start the server
const server = new FlutterMCPServer();
server.start();