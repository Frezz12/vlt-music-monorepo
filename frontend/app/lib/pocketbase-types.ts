/**
* This file was @generated using pocketbase-typegen
*/

import type PocketBase from 'pocketbase'
import type { RecordService } from 'pocketbase'

export enum Collections {
	Authorigins = "_authOrigins",
	Externalauths = "_externalAuths",
	Mfas = "_mfas",
	Otps = "_otps",
	Superusers = "_superusers",
	Draft = "draft",
	Genres = "genres",
	LastReleases = "last_releases",
	MediadiceToken = "mediadice_token",
	Promocodes = "promocodes",
	SocialLinks = "social_links",
	Track = "track",
	Users = "users",
}

// Alias types for improved usability
export type IsoDateString = string
export type IsoAutoDateString = string & { readonly autodate: unique symbol }
export type RecordIdString = string
export type FileNameString = string & { readonly filename: unique symbol }
export type HTMLString = string

type ExpandType<T> = unknown extends T
	? T extends unknown
		? { expand?: unknown }
		: { expand: T }
	: { expand: T }

// System fields
export type BaseSystemFields<T = unknown> = {
	id: RecordIdString
	collectionId: string
	collectionName: Collections
} & ExpandType<T>

export type AuthSystemFields<T = unknown> = {
	email: string
	emailVisibility: boolean
	username: string
	verified: boolean
} & BaseSystemFields<T>

// Record types for each collection

export type AuthoriginsRecord = {
	collectionRef: string
	created: IsoAutoDateString
	fingerprint: string
	id: string
	recordRef: string
	updated: IsoAutoDateString
}

export type ExternalauthsRecord = {
	collectionRef: string
	created: IsoAutoDateString
	id: string
	provider: string
	providerId: string
	recordRef: string
	updated: IsoAutoDateString
}

export type MfasRecord = {
	collectionRef: string
	created: IsoAutoDateString
	id: string
	method: string
	recordRef: string
	updated: IsoAutoDateString
}

export type OtpsRecord = {
	collectionRef: string
	created: IsoAutoDateString
	id: string
	password: string
	recordRef: string
	sentTo?: string
	updated: IsoAutoDateString
}

export type SuperusersRecord = {
	created: IsoAutoDateString
	email: string
	emailVisibility?: boolean
	id: string
	password: string
	tokenKey: string
	updated: IsoAutoDateString
	verified?: boolean
}

export type DraftRecord = {
	author?: RecordIdString
	copiright?: string
	created: IsoAutoDateString
	genre?: string
	id: string
	invate_artist?: string
	logo?: FileNameString
	main_artist?: string
	realese_data?: IsoDateString
	realese_name?: string
	tracks?: RecordIdString[]
	upc?: string
	updated: IsoAutoDateString
	version?: string
}

export type GenresRecord = {
	created: IsoAutoDateString
	genre?: string
	id: string
	updated: IsoAutoDateString
}

export type LastReleasesRecord = {
	artist?: string
	cover?: FileNameString
	created: IsoAutoDateString
	id: string
	title?: string
	updated: IsoAutoDateString
	url_on_track?: string
}

export type MediadiceTokenRecord = {
	created: IsoAutoDateString
	id: string
	mediadice_email?: string
	token?: string
	updated: IsoAutoDateString
}

export type PromocodesRecord = {
	created: IsoAutoDateString
	description?: string
	gift_money?: number
	id: string
	promo_id?: number
	updated: IsoAutoDateString
}

export type SocialLinksRecord = {
	created: IsoAutoDateString
	icon?: string
	id: string
	updated: IsoAutoDateString
	url?: string
	user?: RecordIdString
}

export type TrackRecord = {
	audiofile?: FileNameString
	created: IsoAutoDateString
	fio_authors?: string
	fio_composers?: string
	id: string
	invate_artists?: string
	irsc?: string
	main_artist?: string
	profanity?: boolean
	realese_name?: string
	text?: string
	tiktok_time?: string
	updated: IsoAutoDateString
	version?: string
}

export type UsersRecord = {
	avatar?: FileNameString
	balance?: number
	bonus_balance?: number
	created: IsoAutoDateString
	email: string
	emailVisibility?: boolean
	id: string
	name?: string
	nikname?: string
	password: string
	ref_code?: string
	social_links?: RecordIdString[]
	tokenKey: string
	updated: IsoAutoDateString
	verified?: boolean
}

// Response types include system fields and match responses from the PocketBase API
export type AuthoriginsResponse<Texpand = unknown> = Required<AuthoriginsRecord> & BaseSystemFields<Texpand>
export type ExternalauthsResponse<Texpand = unknown> = Required<ExternalauthsRecord> & BaseSystemFields<Texpand>
export type MfasResponse<Texpand = unknown> = Required<MfasRecord> & BaseSystemFields<Texpand>
export type OtpsResponse<Texpand = unknown> = Required<OtpsRecord> & BaseSystemFields<Texpand>
export type SuperusersResponse<Texpand = unknown> = Required<SuperusersRecord> & AuthSystemFields<Texpand>
export type DraftResponse<Texpand = unknown> = Required<DraftRecord> & BaseSystemFields<Texpand>
export type GenresResponse<Texpand = unknown> = Required<GenresRecord> & BaseSystemFields<Texpand>
export type LastReleasesResponse<Texpand = unknown> = Required<LastReleasesRecord> & BaseSystemFields<Texpand>
export type MediadiceTokenResponse<Texpand = unknown> = Required<MediadiceTokenRecord> & BaseSystemFields<Texpand>
export type PromocodesResponse<Texpand = unknown> = Required<PromocodesRecord> & BaseSystemFields<Texpand>
export type SocialLinksResponse<Texpand = unknown> = Required<SocialLinksRecord> & BaseSystemFields<Texpand>
export type TrackResponse<Texpand = unknown> = Required<TrackRecord> & BaseSystemFields<Texpand>
export type UsersResponse<Texpand = unknown> = Required<UsersRecord> & AuthSystemFields<Texpand>

// Types containing all Records and Responses, useful for creating typing helper functions

export type CollectionRecords = {
	_authOrigins: AuthoriginsRecord
	_externalAuths: ExternalauthsRecord
	_mfas: MfasRecord
	_otps: OtpsRecord
	_superusers: SuperusersRecord
	draft: DraftRecord
	genres: GenresRecord
	last_releases: LastReleasesRecord
	mediadice_token: MediadiceTokenRecord
	promocodes: PromocodesRecord
	social_links: SocialLinksRecord
	track: TrackRecord
	users: UsersRecord
}

export type CollectionResponses = {
	_authOrigins: AuthoriginsResponse
	_externalAuths: ExternalauthsResponse
	_mfas: MfasResponse
	_otps: OtpsResponse
	_superusers: SuperusersResponse
	draft: DraftResponse
	genres: GenresResponse
	last_releases: LastReleasesResponse
	mediadice_token: MediadiceTokenResponse
	promocodes: PromocodesResponse
	social_links: SocialLinksResponse
	track: TrackResponse
	users: UsersResponse
}

// Utility types for create/update operations

type ProcessCreateAndUpdateFields<T> = Omit<{
	// Omit AutoDate fields
	[K in keyof T as Extract<T[K], IsoAutoDateString> extends never ? K : never]: 
		// Convert FileNameString to File
		T[K] extends infer U ? 
			U extends (FileNameString | FileNameString[]) ? 
				U extends any[] ? File[] : File 
			: U
		: never
}, 'id'>

// Create type for Auth collections
export type CreateAuth<T> = {
	id?: RecordIdString
	email: string
	emailVisibility?: boolean
	password: string
	passwordConfirm: string
	verified?: boolean
} & ProcessCreateAndUpdateFields<T>

// Create type for Base collections
export type CreateBase<T> = {
	id?: RecordIdString
} & ProcessCreateAndUpdateFields<T>

// Update type for Auth collections
export type UpdateAuth<T> = Partial<
	Omit<ProcessCreateAndUpdateFields<T>, keyof AuthSystemFields>
> & {
	email?: string
	emailVisibility?: boolean
	oldPassword?: string
	password?: string
	passwordConfirm?: string
	verified?: boolean
}

// Update type for Base collections
export type UpdateBase<T> = Partial<
	Omit<ProcessCreateAndUpdateFields<T>, keyof BaseSystemFields>
>

// Get the correct create type for any collection
export type Create<T extends keyof CollectionResponses> =
	CollectionResponses[T] extends AuthSystemFields
		? CreateAuth<CollectionRecords[T]>
		: CreateBase<CollectionRecords[T]>

// Get the correct update type for any collection
export type Update<T extends keyof CollectionResponses> =
	CollectionResponses[T] extends AuthSystemFields
		? UpdateAuth<CollectionRecords[T]>
		: UpdateBase<CollectionRecords[T]>

// Type for usage with type asserted PocketBase instance
// https://github.com/pocketbase/js-sdk#specify-typescript-definitions

export type TypedPocketBase = {
	collection<T extends keyof CollectionResponses>(
		idOrName: T
	): RecordService<CollectionResponses[T]>
} & PocketBase
