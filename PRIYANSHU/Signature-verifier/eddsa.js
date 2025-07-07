// sign-fixed.mjs  –  Baby‑JubJub EdDSA with proper BigInt coordinates
import { buildBabyjub } from 'circomlibjs';
import { randomBytes, createHash } from 'crypto';
import { writeFileSync } from 'fs';

const babyJub = await buildBabyjub();
const F       = babyJub.F;              // field helper
const L       = babyJub.subOrder;       // subgroup order
const G       = babyJub.Base8;          // generator

/* helper: sha‑256(bytes) → Fr (<L) */
const mask250 = (1n << 250n) - 1n;
function sha256ToFr(buf) {
  const h = createHash('sha256').update(buf).digest();
  return (BigInt('0x' + h.toString('hex')) & mask250) % L;
}
/* helper: (field element | bigint) → bigint */
const toBig = x => (typeof x === 'bigint') ? x : F.toObject(x);
/* helper: bigint → 32‑byte Buffer */
const toBuf = x => Buffer.from(x.toString(16).padStart(64, '0'), 'hex');

/* 1. keypair */
const a  = BigInt('0x' + randomBytes(32).toString('hex')) % L;
const A  = babyJub.mulPointEscalar(G, a);      // field objs
const Ax = toBig(A[0]);
const Ay = toBig(A[1]);

/* 2. message */
const MSG    = 'hello Baby‑JubJub 👋';
const mBytes = Buffer.from(MSG, 'utf8');
const M      = sha256ToFr(mBytes);

/* 3. nonce & R */
const r      = sha256ToFr(Buffer.concat([toBuf(a), mBytes]));
const R      = babyJub.mulPointEscalar(G, r);
const Rx     = toBig(R[0]);
const Ry     = toBig(R[1]);

/* 4. challenge k */
const kInput = Buffer.concat([toBuf(Rx), toBuf(Ry), toBuf(Ax), toBuf(Ay), mBytes]);
const k      = sha256ToFr(kInput);

/* 5. signature scalar s */
const s      = (r + k * a) % L;

/* 6. write JSON */
const out = {
  message: MSG,
  Ax: Ax.toString(),  Ay: Ay.toString(),
  Rx: Rx.toString(),  Ry: Ry.toString(),
  s :  s.toString(),  M :  M.toString()
};
writeFileSync('signature.json', JSON.stringify(out, null, 2));
console.log('✅  signature.json written with BigInt coordinates');
