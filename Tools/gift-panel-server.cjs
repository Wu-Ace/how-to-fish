const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const catalog = JSON.parse(fs.readFileSync(path.join(__dirname, 'gift-catalog.json'), 'utf8'));
const allowed = new Set(catalog.map(x => x.id));
const server = http.createServer((req, res) => {
  const url = new URL(req.url, 'http://127.0.0.1:6092');
  if (req.method === 'GET' && url.pathname === '/') {
    res.writeHead(200, {'Content-Type':'text/html; charset=utf-8'});
    return res.end(fs.readFileSync(path.join(__dirname, 'gift-panel.html')));
  }
  if (req.method === 'GET' && url.pathname === '/catalog.json') {
    res.writeHead(200, {'Content-Type':'application/json; charset=utf-8'});
    return res.end(JSON.stringify(catalog));
  }
  const match = /^\/(original|sandbox)\/api\/(.+)$/.exec(url.pathname);
  if (!match || !((req.method === 'GET' && ['state','effects','health'].includes(match[2])) ||
     (req.method === 'POST' && allowed.has(match[2])))) { res.writeHead(404); return res.end(); }
  const port = match[1] === 'original' ? 6090 : 6091;
  let body = '';
  req.on('data', data => { body += data; if (body.length > 8192) req.destroy(); });
  req.on('end', () => {
    const upstream = http.request({hostname:'127.0.0.1', port, path:'/api/'+match[2], method:req.method,
      headers:{'Content-Type':'application/json', 'Content-Length':Buffer.byteLength(body)}, timeout:3000}, response => {
        res.writeHead(response.statusCode, {'Content-Type':'application/json; charset=utf-8'});
        response.pipe(res);
      });
    upstream.on('timeout', () => upstream.destroy());
    upstream.on('error', () => { if (!res.headersSent) res.writeHead(503, {'Content-Type':'application/json'}); res.end(JSON.stringify({ok:false,message:'游戏尚未启动或本地接口未就绪'})); });
    upstream.end(body);
  });
});
server.on('error', error => { console.error(error.message); process.exitCode=1; });
server.listen(6092, '127.0.0.1', () => console.log('礼物控制台 http://127.0.0.1:6092'));
